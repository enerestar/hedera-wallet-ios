//
//  RestoreAccountIDViewController.swift
//  HGCApp
//
//  Created by Surendra on 25/01/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit
import ActiveLabel

class RestoreAccountIDViewController: UIViewController {

    private var seed:HGCSeed!
    private var sigantureOption : SignatureOption!

    @IBOutlet weak var messageLabel : ActiveLabel!
    @IBOutlet weak var textField : HGCTextField!

    static func getInstance(_ signatureOption:SignatureOption, _ seed : HGCSeed) -> RestoreAccountIDViewController {
        let vc = Globals.welcomeStoryboard().instantiateViewController(withIdentifier: "restoreAccountIDViewController") as! RestoreAccountIDViewController
        vc.seed = seed
        vc.sigantureOption = signatureOption
        vc.title = NSLocalizedString("Enter Account ID", comment: "")
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.textField.placeholder = NSLocalizedString("ACCOUNTID_PLACEHOLDER", comment: "")
        messageLabel.textColor = Color.primaryTextColor()
        messageLabel.font = Font.regularFontLarge()
        let customType = ActiveType.custom(pattern: "\\shedera portal\\b") //Looks for "supports"
        messageLabel.enabledTypes = [customType]
        messageLabel.text = NSLocalizedString("ACCOUNTID_RESTORE_MESSAGE", comment: "")
        messageLabel.customColor[customType] = Color.tintColor()
        messageLabel.customSelectedColor[customType] = Color.primaryTextColor()
        messageLabel.handleCustomTap(for: customType) {_ in
            if let url = URL(string: portalFAQRestoreAccount) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }
            }
        }
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDoneButtonTap() {
        let accountID = HGCAccountID.init(from: self.textField.text?.trim())
        Globals.showGenericAlert(title: NSLocalizedString("Wallet restored successfully", comment: ""), message: "")
        let vc = PINSetupViewController.getInstance(sigantureOption, seed, accountID)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
