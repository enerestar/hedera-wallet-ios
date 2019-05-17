//
//  PrivacyPolicyViewController.swift
//  HGCApp
//
//  Created by Surendra on 12/12/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var textView : UITextView!

    static func getInstance() -> PrivacyPolicyViewController {
        return Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "privacyPolicyViewController") as! PrivacyPolicyViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("PRIVACY POLICY", comment: "")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.navigationItem.backBarButtonItem = Globals.emptyBackBarButton()
        let string = try! String.init(contentsOf: Bundle.main.url(forResource: "privacy", withExtension: "txt")!)
        self.textView.text = string
       
        
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
}
