//
//  HGCContact+CoreDataClass.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//
//

import Foundation
import CoreData

extension HGCContact {
    public static let entityName  = "Contact"
    
    static func getContact(_ address:String) -> HGCContact? {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest = HGCContact.fetchRequest() as NSFetchRequest<HGCContact>
        fetchRequest.predicate = NSPredicate(format: "publicKeyID == %@", address)
        let result = try? context.fetch(fetchRequest)
        if result != nil && (result?.count)! > 0 {
            return result?.first
        }
        return nil
    }
    
    static func getAllContacts() -> [HGCContact] {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest = HGCContact.fetchRequest() as NSFetchRequest<HGCContact>
        let sortDesc1 = NSSortDescriptor.init(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc1]
        let result = try? context.fetch(fetchRequest)
        if result != nil {
            return result!
        }
        return []
    }
    
    static func alias(_ accID:String) -> String? {
        if let alias = HGCContact.getContact(accID) {
            return alias.name
        } else if let account = HGCWallet.masterWallet()?.accountWithAccountID(accID) {
            return account.name
        }
        return nil
    }
    
    @discardableResult
    static func addAlias(name:String?, address:String) -> HGCContact? {
        if address.isEmpty { return nil}
        if let alias = HGCContact.getContact(address) {
            alias.name = name
            CoreDataManager.shared.saveContext()
            return alias
            
        } else {
            let context = CoreDataManager.shared.mainContext
            let contact = NSEntityDescription.insertNewObject(forEntityName: HGCContact.entityName, into: context) as! HGCContact
            contact.name = name
            contact.publicKeyID = address
            CoreDataManager.shared.saveContext()
            return contact
        }
        
    }
    
    static func isVarified(name:String?, address:String?) -> Bool {
        
        if name == nil || address == nil { return false}
        if name!.isEmpty || address!.isEmpty { return false}
        if let account = HGCWallet.masterWallet()?.accountWithAccountID(address!) {
            if account.name == name {
                return true
            }
        }
        
        if let alias = HGCContact.getContact(address!) {
            if alias.name == name {
                return alias.verified
            }
        }
        
        return false
    }
}
