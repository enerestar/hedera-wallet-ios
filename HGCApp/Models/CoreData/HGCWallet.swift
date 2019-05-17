//
//  HGCWallet+CoreDataClass.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//
//

import Foundation
import CoreData

extension HGCWallet {
    public static let entityName  = "Wallet"
    func keyChain() -> HGCKeyChainProtocol? {
        return WalletHelper.keyChain()
    }
    
    func signatureOption() -> SignatureOption {
        if let option : SignatureOption = SignatureOption(rawValue: Int(self.signatureAlgorithm)) {
            return option
        }
        return .ED25519
    }
    
    class func masterWallet(_ context : NSManagedObjectContext = CoreDataManager.shared.mainContext) -> HGCWallet? {
        let result = try? context.fetch(HGCWallet.fetchRequest() as NSFetchRequest<HGCWallet>)
        return (result?.first)
    }
    
    class func createMasterWallet(signatureAlgorith: Int16, accountID:HGCAccountID? = nil, coreDataManager : CoreDataManagerProtocol = CoreDataManager.shared) {
        let context = coreDataManager.mainContext
        let result = try? context.fetch(HGCWallet.fetchRequest() as NSFetchRequest<HGCWallet>)
        if  result == nil || result?.count == 0 {
            let wallet = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! HGCWallet
            wallet.walletId = 0
            wallet.signatureAlgorithm = signatureAlgorith
            let acc = wallet.createDefaultAccount(coreDataManager)
            if let accID = accountID {
                acc.accountId = accID.accountId
                acc.realmId = accID.realmId
                acc.shardId = accID.shardId
            }
            coreDataManager.saveContext()
        }
    }
    
    func createNewAccount(_ coreDataManager : CoreDataManagerProtocol = CoreDataManager.shared) -> HGCAccount {
        let context = coreDataManager.mainContext
        let account = NSEntityDescription.insertNewObject(forEntityName: HGCAccount.entityName, into: context) as! HGCAccount
        account.wallet = self
        account.accountNumber = self.numAccounts
        account.creationDate = Date()
        account.balance = 0
        account.name = ""
        self.numAccounts = account.accountNumber + 1
        coreDataManager.saveContext()
        return account
    }
    
    func createDefaultAccount(_ coreDataManager : CoreDataManagerProtocol = CoreDataManager.shared) -> HGCAccount {
        let account = self.createNewAccount(coreDataManager)
        account.name = "Default Account"
        CoreDataManager.shared.saveContext()
        return account
    }
    
    func allAccounts() -> [HGCAccount] {
        if let set = self.accounts {
            let sortDesc = NSSortDescriptor.init(key: "creationDate", ascending: true)
            return set.sortedArray(using: [sortDesc]) as! [HGCAccount]
        }
        return [HGCAccount]()
    }
    
    func accountWithAccountID(_ accountID:String) -> HGCAccount? {
        if let set = self.accounts?.allObjects as? [HGCAccount] {
            for account in set {
                if let accID = account.accountID() {
                    if accountID.lowercased() == accID.stringRepresentation().lowercased() {
                        return account
                    }
                }
            }
        }
        
        return nil
    }
    
    func accountWithPublicKey(_ publicKey:String) -> HGCAccount? {
        if let set = self.accounts?.allObjects as? [HGCAccount] {
            for account in set {
                if publicKey.lowercased() == account.publicKeyString().lowercased() {
                    return account
                }
            }
        }

        return nil
    }
    
    func totalBalance() -> Int64 {
        var total : Int64 = 0
        for acconut in self.allAccounts() {
            total = acconut.balance + total
        }
        return total
    }
}
