//
//  Bip39MigrationViewController.swift
//  HGCApp
//
//  Created by Surendra on 12/02/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

class Bip39MigrationViewController: UIViewController {

    @IBOutlet weak var doneButton : UIButton!
    @IBOutlet weak var backupPhraseLabel : UILabel!
    @IBOutlet weak var messageLabel : UILabel!
    
    private var seed : HGCSeed!
    private var words: [String]!
    static func getInstance(seed:HGCSeed) -> Bip39MigrationViewController {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "bip39MigrationViewController") as! Bip39MigrationViewController
        vc.seed = seed
        vc.words = seed.toBIP39Words()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.backupPhraseLabel.textColor = Color.primaryTextColor()
        self.backupPhraseLabel.font = Font.regularFontLarge()
        
        self.messageLabel.textColor = Color.primaryTextColor()
        self.messageLabel.font = Font.regularFontVeryLarge()

        backupPhraseLabel.text = words.joined(separator: "    ")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppSettings.setHasShownBip39Mnemonic()
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCopyButtonTap() {
        let s = words.joined(separator: " ")
        Globals.copyString(s)
        Globals.showGenericAlert(title: NSLocalizedString("Copied", comment: ""), message:NSLocalizedString("Backup phrase is copied successfully.", comment: ""))
    }
    
    @IBAction func onDoneButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }

}
