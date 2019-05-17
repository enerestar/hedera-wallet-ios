//
//  OnboardingViewController.swift
//  HGCApp
//
//  Created by Surendra  on 17/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    private var embededNavCtrl : UINavigationController!
    
    static func getInstance() -> OnboardingViewController {
        return Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "onboardingViewController") as! OnboardingViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            self.embededNavCtrl = navVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Get Started on Hedera", comment: "")
        
        self.embededNavCtrl.navigationBar.barTintColor = Color.titleBarBackgroundColor()
        self.embededNavCtrl.navigationBar.tintColor = Color.primaryTextColor()
        self.embededNavCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Color.primaryTextColor(), NSAttributedString.Key.font : Font.lightFontVeryLarge()]
        Globals.hideBottomLine(navBar: self.embededNavCtrl.navigationBar)
    }
}
