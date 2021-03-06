//
//  AppDelegate.swift
//  HGCApp
//
//  Created by Surendra  on 23/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var window: UIWindow?
    private var splashWindow: UIWindow?
    static var authManager : AuthManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // setup UI
        setupWindows()
        HGCStyle.customizeAppearance();
        
        // load address book
        _ = APIAddressBookService.defaultAddressBook
        
        // register branch.io instance
        setupBranchIO(launchOptions)
        
        if WalletHelper.isOnboarded() {
            // Authenticate
            AppDelegate.authManager.authenticate(AppDelegate.authManager.currentAuthType(), animated: false)
        }
    
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let branchHandled = Branch.getInstance().application(app, open: url, options: options)
        if !branchHandled {
            RedirectManager.shared.onUrlReceived(url)
        }
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let branchHandled = Branch.getInstance().continue(userActivity)
        return branchHandled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        splashWindow?.isHidden = false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        splashWindow?.isHidden = true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        splashWindow?.isHidden = true
        if WalletHelper.isOnboarded() && AppDelegate.authManager.shouldAskForAuth() {
            AppDelegate.authManager.authenticate(AppDelegate.authManager.currentAuthType(), animated: false)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
}

extension AppDelegate {
    static func getInstance() -> AppDelegate {
        return UIApplication.shared.delegate! as! AppDelegate
    }
    
    func setupWindows() {
        splashWindow = UIWindow.init(frame: UIScreen.main.bounds)
        splashWindow?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: Bundle.main).instantiateInitialViewController()
        splashWindow?.windowLevel = UIWindow.Level.init(rawValue: 3)
        window = UIWindow.init(frame: UIScreen.main.bounds)
        AppDelegate.authManager = AuthManager.init(mainWindow: window!)
        if WalletHelper.isOnboarded() {
            window?.rootViewController = mainViewController()
            window?.makeKeyAndVisible()
        } else {
            NotificationCenter.default.addObserver(self, selector:#selector(AppDelegate.onOnboardDidSuccess), name:WalletHelper.onboardDidSuccess, object: nil)
            window?.rootViewController = welcomeViewController()
            window?.makeKeyAndVisible()
        }
    }
    
    func slideMenuController() -> LGSideMenuController? {
        if let vc = self.window?.rootViewController as? LGSideMenuController {
            return vc
        }
        return nil
    }
    
    func mainViewController() -> UIViewController {
        let centerViewController = ContainerViewController.getInstance();
        let navigationController = UINavigationController.init(rootViewController: centerViewController);
        Globals.hideBottomLine(navBar: navigationController.navigationBar)
        
        let sideMenu = LeftMenuViewController.getInstance();
        sideMenu.delegate = centerViewController
        sideMenu.view.backgroundColor = Color.sideMenuBackgroundColor()
        let sideMenuController = LGSideMenuController.init(rootViewController: navigationController, leftViewController: nil, rightViewController: sideMenu)
        sideMenuController.rightViewWidth = 260.0;
        sideMenuController.leftViewPresentationStyle = .slideBelow;
        sideMenuController.rightViewBackgroundColor = Color.sideMenuBackgroundColor()
        sideMenuController.leftViewBackgroundColor = Color.sideMenuBackgroundColor()

        return sideMenuController
    }
    
    func welcomeViewController() -> UIViewController {
        let vc  = OnboardingViewController.getInstance()
        let navVC = UINavigationController.init(rootViewController: vc)
        return navVC
    }
    
    @objc func onOnboardDidSuccess() {
        let mainVC = self.mainViewController();
        UIView.transition(from: (self.window?.rootViewController?.view)!, to: (mainVC.view)!, duration: 0.5, options: .transitionFlipFromLeft) { (finished: Bool) in
            self.window?.rootViewController = mainVC
        }
    }
    
    func setupBranchIO(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.setUseTestBranchKey(isDevMode)
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            if error == nil {
                if let banchParams = params as? [String: Any] {
                    Logger.instance.log(message: banchParams.description, event: .i)
                    
                    RedirectManager.shared.onBranchParamsReceived(banchParams)
                }
            } else {
                Logger.instance.log(message: error!.localizedDescription, event: .e)
            }
        })
    }
}


