//
//  ContainerViewController.swift
//  HGCApp
//
//  Created by Surendra  on 21/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

enum HGCTab {
    case home, accounts, requests, settings
}

class ContentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
}

class ContainerViewController: UIViewController {

    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var warningContainer : UIView!
    @IBOutlet weak var warningLabel : UILabel!

    @IBOutlet weak var warningContainerHeight : NSLayoutConstraint!

    private var embededNavCtrl : UINavigationController!
    private var selectedTab = HGCTab.home
    
    private let statusBarBackgroundView = UIView.init()
    
    private var shouldRedirectToRequests = false

    static func getInstance() -> ContainerViewController {
        return Globals.mainStoryboard().instantiateViewController(withIdentifier: "containerViewController") as! ContainerViewController
    }
    
    func slideNavigationControllerShouldDisplayRightMenu() -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            self.embededNavCtrl = navVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        let homeButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        homeButton.setImage(UIImage.init(named: "Hbar_grey-white-40"), for: .normal)
        homeButton.contentEdgeInsets.left = -12
        homeButton.addTarget(self, action:  #selector(onHomeBuutonTap), for: .touchUpInside)
        
        let refreshButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        refreshButton.setImage(UIImage.init(named: "icon-sync"), for: .normal)
        refreshButton.contentEdgeInsets.right = -30
        refreshButton.addTarget(self, action:  #selector(openSync), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: homeButton)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(image: UIImage.init(named: "icon-menu"), style: .plain, target: self, action: #selector(onMenuButtonTap)), UIBarButtonItem.init(customView: refreshButton)]
        
        self.embededNavCtrl.navigationBar.barTintColor = Color.titleBarBackgroundColor()
        self.embededNavCtrl.navigationBar.tintColor = Color.primaryTextColor()
        self.embededNavCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Color.primaryTextColor(), NSAttributedString.Key.font : Font.lightFontVeryLarge()]
        Globals.hideBottomLine(navBar: self.embededNavCtrl.navigationBar)
        statusBarBackgroundView.backgroundColor = Color.tabBackgroundColor()
        self.navigationController?.view.addSubview(statusBarBackgroundView)
        
        warningLabel.font = Font.lightFontSmall();
        warningContainer.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(ContainerViewController.showBip39MigrationAlertIfNeeded)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onRedirectObjectReceived), name: .onRedirectObjectReceived, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAppWarning(show: !AppSettings.hasShownBip39Mnemonic(), animated: true) {}
    }
    
    func showAppWarning(show:Bool, animated:Bool, competion:@escaping () -> Void) {
        if !show {
            NSLayoutConstraint.activate([warningContainerHeight])
        } else {
            NSLayoutConstraint.deactivate([warningContainerHeight])
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }) { (finished) in
            competion()
        }
    }
    
    @objc func onRedirectObjectReceived(notif:Notification) {
        if let intentParser = notif.object as? IntentParser {
            switch intentParser.intent {
            case .transferRequest:
                setTab(.requests)
            case .linkAccount:
                break
            case .linkAccountRequest:
                break
            }
            RedirectManager.shared.redirectionHandled()
        }
    }
    
    @objc func showBip39MigrationAlertIfNeeded() {
        showAppWarning(show: false, animated: true) {
            if let seed = SecureAppSettings.default.getSeed(), let hgcSeed = HGCSeed.init(entropy: seed) {
                let vc = Bip39MigrationViewController.getInstance(seed: hgcSeed)
                vc.title = NSLocalizedString("Backup your wallet", comment: "")
                self.pushPage(vc)
            }
        }
        
//        UIAlertController.alert(title: NSLocalizedString("BIP39_MIGRATION_ALERT_TITLE", comment: ""), message: NSLocalizedString("BIP39_MIGRATION_ALERT_MESSAGE", comment: "")).addDismissButton().addConfirmButton(title: NSLocalizedString("See details", comment: "")) { (action) in
//            if let seed = SecureAppSettings.default.getSeed(), let hgcSeed = HGCSeed.init(entropy: seed) {
//                let vc = Bip39MigrationViewController.getInstance(seed: hgcSeed)
//                vc.title = NSLocalizedString("Backup your wallet", comment: "")
//                self.pushPage(vc)
//            }
//            }.showAlert()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusBarBackgroundView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: UIApplication.shared.statusBarFrame.size.height)
    }
    
    func setTab(_ tab: HGCTab) {
        if self.selectedTab == tab {
            self.embededNavCtrl.popToRootViewController(animated: true)
            
        } else {
            self.selectedTab = tab
            var vc : UIViewController!
            switch self.selectedTab {
            case .home:
                vc = OverviewViewController.getInstance()
            case .accounts:
                vc = AccountListViewController.getInstance()
            case .settings:
                vc = SettingsTableViewController.getInstance()
            case .requests:
                vc = RequestListViewController.getInstance()
            }
            self.embededNavCtrl.viewControllers = [vc]
        }
    }
    
    @objc func onMenuButtonTap() {
        AppDelegate.getInstance().slideMenuController()?.rightViewController?.viewWillAppear(false)
        AppDelegate.getInstance().slideMenuController()?.showRightView(animated: true, completionHandler: {
            
        })
    }
    
    @objc func onHomeBuutonTap() {
        if self.selectedTab == .home {
            if let overviewVC = self.embededNavCtrl.viewControllers[0] as? OverviewViewController {
                overviewVC.showDetailConatiner(false, animated: true)
            }
        }
        self.setTab(.home)
        
    }

    @IBAction func onRequestsButtonTap() {
        setTab(.requests)
    }
    
    @IBAction func onAccountsButtonTap() {
        setTab(.accounts)
    }
    
    @IBAction func onSettingsButtonTap() {
        setTab(.settings)
    }
}

extension ContainerViewController : LeftMenuViewControllerDelegate {
    func pushPage(_ page: UIViewController) {
        self.embededNavCtrl.pushViewController(page, animated: true)
    }
    
    func switchPage(_ page: UIViewController) {
        self.embededNavCtrl.viewControllers = [page]
    }
    
    @objc func openSync() {
        let onSync = {
            self.onHomeBuutonTap()
            WalletHelper.syncData()
        }
        
        if !AppSettings.askedForQueryCostWarning() {
            Globals.showConfirmationAlert(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("SYNC_WARNING", comment: ""), onConfirm: {
                AppSettings.setAskedForQueryCostWarning(true)
                onSync()
            }) {
                
            }
        } else {
            onSync()
        }
    }
    
    func openAbout() {
        let vc = AboutViewController.getInstance()
        self.embededNavCtrl.pushViewController(vc, animated: true)
    }
    
    func exportKey() {
        if let err = ExportKeysNavigationVC.canExport() {
            Globals.showGenericErrorAlert(title: NSLocalizedString("Can't export", comment: ""), message: err)
        } else {
            let navVC = ExportKeysNavigationVC.getInstance()
            self.present(navVC, animated: true, completion: nil)
        }
        
    }
}
