//
//  APIAddressBookService.swift
//  HGCApp
//
//  Created by Surendra  on 30/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import SwiftyJSON

class APIAddressBookService {
    static let defaultAddressBook : APIAddressBookService = APIAddressBookService.init();
    private var hash : String?
    private var nodes = [HGCNodeVO]()
    
    init() {
        loadList()
    }
    
    func loadList() {
        let list = getList()
        nodes = list.map({ (node) -> HGCNodeVO in
            return node.nodeVO()
        })
    }
    
    private func getList() -> [HGCNode] {
        var nodes = HGCNode.getAllNodes(activeOnly: true)
        if nodes.count <= 0 {
            loadListFromFile()
            nodes = HGCNode.getAllNodes(activeOnly: true)
        }
        return nodes
    }
    
    private func loadListFromFile() {
        let url = Bundle.main.url(forResource: nodeListFileName, withExtension: "")
        do {
            let data = try NSData(contentsOf: url!, options: NSData.ReadingOptions())
            let object = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
            if let items = object as? [[String : Any]] {
                items.forEach { (map) in
                    if let node = HGCNodeVO.init(map:map) {
                        nodes.append(node)
                        HGCNode.addNode(nodeVO: node)
                    }
                }
                CoreDataManager.shared.saveContext()
            }
        } catch {
            
        }
    }
    
    func randomNode() -> HGCNodeVO {
        if nodes.count > 0 {
            let index = Int(arc4random_uniform(UInt32(nodes.count)))
            if index >= 0 && index < nodes.count {
                return nodes[index]
            }
        }
        return HGCNode.getAllNodes(activeOnly: false).first!.nodeVO()
    }

}

class HGCNodeVO {
    let host: String
    let port: Int32
    let accountID:HGCAccountID

    init(host:String, port:Int32, accountID:HGCAccountID) {
        self.host = host
        self.port = port
        self.accountID = accountID
    }
    
    init?(map:[String:Any]) {
        let json = JSON(map)
        self.host = json["host"].stringValue
        self.port = json["port"].int32Value
        self.accountID = HGCAccountID.init(shardId: json["shardNum"].int64Value, realmId: json["realmNum"].int64Value, accountId: json["accountNum"].int64Value)
    }
    
    func address() -> String {
        return host + ":" + port.description
    }
}
