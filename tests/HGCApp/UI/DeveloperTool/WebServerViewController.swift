//
//  WebServerViewController.swift
//  HGCApp
//
//  Created by Surendra on 30/10/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

class ExportKeysNavigationVC: UINavigationController, ScanViewControllerDelegate, AccountPickerDelegate {
    var exportAccount:HGCAccount!

    static func getInstance() -> ExportKeysNavigationVC {
        let vc = AccountListViewController.getInstance()
        vc.pickeMode = true
        let navVC = ExportKeysNavigationVC.init(rootViewController: vc)
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: navVC, action: #selector(ExportKeysNavigationVC.onCancel))
        vc.delegate = navVC
        return navVC
    }
    
    @objc func onCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func scanViewControllerDidCancel(_ vc: ScanViewController) {
        onCancel()
    }
    
    func accountPickerDidPickAccount(_ picker: AccountListViewController, accont: HGCAccount) {
        self.exportAccount = accont
        let scanVC = ScanViewController.getInstance()
        scanVC.title = NSLocalizedString("EXPORT_KEY_PAGE_TITLE", comment: "")
        scanVC.delegate = self
        scanVC.navigationItem.hidesBackButton = true
        self.pushViewController(scanVC, animated: true)
    }
    
    func scanViewControllerDidScan(_ vc: ScanViewController, results: [String]) {
        if let result = results.first {
            if let params = PairingParams.init(result) {
                let webServerVC = WebServerViewController.getInstance(params, exportAccount)
                pushViewController(webServerVC, animated: true)
                vc.stopScan()
            }
        }
    }
    
    
    
    static func canExport() -> String? {
        let t = IPUtility.getMyIP()
        if t.network ==  IPUtility.Wifi {
            return nil
        } else {
            return NSLocalizedString("EXPORT_KEY_NO_WIFI_ERROR_MESSAGE", comment: "")
        }
    }
}

class WebServerViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var logsTextView: UITextView!
    
    var account:HGCAccount!
    var webServer: WebServer!
    
    static func getInstance(_ params:PairingParams, _ account:HGCAccount) -> WebServerViewController {
        let vc = Globals.developerToolsStoryboard().instantiateViewController(withIdentifier: "webServerViewController") as! WebServerViewController
        vc.account = account
        vc.webServer = WebServer.init(params: params)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("EXPORT_KEY_PAGE_TITLE", comment: "")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
        logsTextView.isHidden = true
        logsTextView.text = ""
        logsTextView.contentInset.bottom = 100
        webServer.delegate = self
        webServer.startServer()
        ipLabel.text = webServer.getPIN()
    }
    
    @objc func onCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        webServer.stopServer()
    }
}

extension WebServerViewController : WebServerProtocol {
    
    func log(value: String) {
        //let text = logsTextView.text!
        //let string = text + "\n"  + value
        //logsTextView.text = string
    }
    
    func getAccount() -> HGCAccount? {
        return account
    }
    
    func requestHandled() {
        self.dismiss(animated: true, completion: nil)
    }
}
