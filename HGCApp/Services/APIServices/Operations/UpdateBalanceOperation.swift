//
//  UpdateBalanceOperation.swift
//  HGCApp
//
//  Created by Surendra on 26/08/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import Foundation
import CoreData
import SwiftGRPC

class UpdateBalanceOperation : BaseOperation {
    private var coreDataManager = CoreDataManager.shared
    
    override func main() {
        super.main()
        NotificationCenter.default.post(name: .onBalanceServiceStateChanged, object: nil)
        let context = coreDataManager.mainContext
        if let wallet = HGCWallet.masterWallet(context) {
            self.fetchBalance(accounts: wallet.allAccounts(), context: context)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            NotificationCenter.default.post(name: .onBalanceServiceStateChanged, object: nil)
        }
        
    }
    
    private func fetchBalance(accounts : [HGCAccount], context:NSManagedObjectContext) {
        if accounts.count <= 0 { return }
        let payerAccount = accounts.first!
        var errors = Set<String>()
        for account in accounts {
            if let accID = account.accountID() {
                let q = APIRequestBuilder.getBalanceQuery(fromAccount: payerAccount, accountID: accID, node: node.accountID)
                Logger.instance.log(message: q.textFormatString(), event: .i)
               
                do {
                    let response = try cryptoClient.cryptoGetBalance(q)
                    Logger.instance.log(message: response.textFormatString(), event: .i)
                    let status = response.cryptogetAccountBalance.header.nodeTransactionPrecheckCode
                    switch status {
                    case .ok:
                        let bal = response.cryptogetAccountBalance
                        account.balance = Int64(bal.balance)
                        account.lastBalanceCheck = Date()
                    case .invalidAccountID:
                        account.clearData()
                        errors.insert("\(NSLocalizedString("invalidAccountID", comment: "")) \(accID.stringRepresentation())")
                    case .payerAccountNotFound:
                        account.clearData()
                        errors.insert("\(NSLocalizedString("payerAccountNotFound", comment: "")) \(accID.stringRepresentation())")
                        break
                    default:
                        errors.insert(status.getErrorMessage())
                    }
                    
                } catch {
                    errors.insert(desc(error))
                    Logger.instance.log(message:desc(error), event: .i)
                    break
                }
            }
        }
        self.coreDataManager.saveContext()
        
        if !errors.isEmpty {
            errorMessage = errors.joined(separator: "\n")
        }
    }
}
