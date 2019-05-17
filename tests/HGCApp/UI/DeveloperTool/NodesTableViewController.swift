//
//  NodesTableViewController.swift
//  HGCApp
//
//  Created by Surendra on 21/09/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

class NodesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var nodes = [HGCNode]()
    @IBOutlet weak var tableView:UITableView!

    static func getInstance() -> NodesTableViewController {
        return Globals.developerToolsStoryboard().instantiateViewController(withIdentifier: "nodesTableViewController") as! NodesTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("NODES", comment: "")
        _ = APIAddressBookService.defaultAddressBook;
        if allowEditingNet {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title:NSLocalizedString("Add", comment: ""), style: .plain, target: self, action: #selector(NodesTableViewController.onAddButtonTap))
        }
        self.tableView.backgroundColor = Color.pageBackgroundColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nodes = HGCNode.getAllNodes(activeOnly: false)
        self.tableView.reloadData()
    }
    
    @IBAction func onAddButtonTap() {
        let vc = ChangeIPViewController.getInstance(node: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        let node = nodes[indexPath.row]
        let nodeVO = node.nodeVO()
        cell.textLabel?.text = nodeVO.address()
        cell.detailTextLabel?.text = nodeVO.accountID.stringRepresentation()
        cell.accessoryType = !allowEditingNet ? .none : .disclosureIndicator;
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let node = nodes[indexPath.row]
        cell.textLabel?.textColor = !node.disabled ? UIColor.black : UIColor.gray
        cell.detailTextLabel?.textColor = !node.disabled ? UIColor.black : UIColor.gray
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowEditingNet {
            let vc = ChangeIPViewController.getInstance(node: nodes[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
