//
//  HGCNode.swift
//  HGCApp
//
//  Created by Surendra on 21/09/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import Foundation
import CoreData

extension HGCNode {
    public static let entityName  = "Node"
    static func getAllNodes(activeOnly:Bool = true) -> [HGCNode] {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest = HGCNode.fetchRequest() as NSFetchRequest<HGCNode>
        if activeOnly {
            fetchRequest.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [NSCompoundPredicate.init(orPredicateWithSubpredicates: [NSPredicate(format: "status == 'active'"), NSPredicate(format: "status == 'unknown'")]),NSPredicate(format: "disabled == NO")])
        }
        
        let result = try? context.fetch(fetchRequest)
        if result != nil {
            return result!
        }
        return []
    }
    
    static func getNode(_ host:String) -> HGCNode? {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest = HGCNode.fetchRequest() as NSFetchRequest<HGCNode>
        fetchRequest.predicate = NSPredicate(format: "host == %@", host)
        let result = try? context.fetch(fetchRequest)
        if result != nil && (result?.count)! > 0 {
            return result?.first
        }
        return nil
    }
    
    @discardableResult
    static func addNode(nodeVO:HGCNodeVO) -> HGCNode {
        if let node = HGCNode.getNode(nodeVO.host) {
            return node
            
        } else {
            let context = CoreDataManager.shared.mainContext
            let node = NSEntityDescription.insertNewObject(forEntityName: HGCNode.entityName, into: context) as! HGCNode
            node.host = nodeVO.host
            node.port = nodeVO.port
            node.accountNum = nodeVO.accountID.accountId
            node.realmNum = nodeVO.accountID.realmId
            node.shardNum = nodeVO.accountID.shardId
            return node
        }
        
    }
    
    func nodeVO() -> HGCNodeVO {
        return HGCNodeVO.init(host: host!, port: port, accountID: HGCAccountID.init(shardId: shardNum, realmId: realmNum, accountId: accountNum))
    }
}
