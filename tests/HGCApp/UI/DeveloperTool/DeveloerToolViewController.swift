//
//  DeveloerToolViewController.swift
//  HGCApp
//
//  Created by Surendra on 16/06/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit
import MessageUI

class DeveloerToolViewController: UIViewController {
    @IBOutlet weak var tableView : UITableView!
    var menus : Array<String>!;

    private var embededNavCtrl : UINavigationController!
    
    static func getInstance() -> DeveloerToolViewController {
        return Globals.developerToolsStoryboard().instantiateViewController(withIdentifier: "develoerToolViewController") as! DeveloerToolViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            self.embededNavCtrl = navVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Developer Tool"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-cross"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.backBarButtonItem = Globals.emptyBackBarButton()
        self.menus = Array.init(arrayLiteral: "Manage Nodes","Logs");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pushToChangeIp() {
        let vc = NodesTableViewController.getInstance()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func emailLogs() {
        if !MFMailComposeViewController.canSendMail() {
            Globals.showGenericErrorAlert(title: "Cannot send email", message: "")
            return
        }
        let s = Logger.instance.logs.joined(separator: "\n")
        let emailComposer = MFMailComposeViewController.init()
        emailComposer.setMessageBody(s, isHTML: false)
        emailComposer.mailComposeDelegate = self
        self.present(emailComposer, animated: true) {
            
        }
    }
    @IBAction func back() {
        navigationController?.dismiss(animated: true, completion:nil)
    }

}

extension DeveloerToolViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.menus[indexPath.row];
        cell.accessoryType = .disclosureIndicator
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0 :
        self.pushToChangeIp()
            break
        case 1:
            self.emailLogs()
        default: break
        }
    }
}

extension DeveloerToolViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true) {
            
        }
    }
}
