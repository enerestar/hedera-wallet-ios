//
//  UpdateTransactionsOperation.swift
//  HGCApp
//
//  Created by Surendra on 26/08/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import Foundation
import CoreData

extension String : Error {
    
}

class UpdateTransactionsOperation : BaseOperation {
    private var coreDataManager = CoreDataManager.shared
    
    override func main() {
        super.main()
        NotificationCenter.default.post(name: .onTransactionsServiceStateChanged, object: nil)
        let context = coreDataManager.mainContext
        if let wallet = HGCWallet.masterWallet(context) {
            self.fetchHistory(accounts: wallet.allAccounts(), context:context)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            NotificationCenter.default.post(name: .onTransactionsServiceStateChanged, object: nil)
        }
    }
    
    private func fetchHistory(accounts : [HGCAccount], context:NSManagedObjectContext) {
        if accounts.count <= 0 { return }
        let payerAccount = accounts.first!
        var errors = Set<String>()
        for account in accounts {
            if let accID = account.account().accountID {
                do {
                    let cost = try fetchCost(payerAccount, accID)
                    let r = APIRequestBuilder.getAccountRecordQuery(fromAccount: payerAccount, accountID: accID, node: node.accountID, fee: cost)
                    Logger.instance.log(message: r.textFormatString(), event: .i)
                    
                    let queryResponse = try cryptoClient.getAccountRecords(r)
                    Logger.instance.log(message: queryResponse.textFormatString(), event: .i)
                    let status = queryResponse.cryptoGetAccountRecords.header.nodeTransactionPrecheckCode
                    switch status {
                    case .ok:
                        let records = queryResponse.cryptoGetAccountRecords.records
                        for record in records {
                            HGCRecord.getOrCreateTxn(pTxnRecord: record, context: context)
                        }
                    case .payerAccountNotFound:
                        errors.insert("\(NSLocalizedString("payerAccountNotFound", comment: "")) \(payerAccount.accountID()!.stringRepresentation())")
                        break
                    case .invalidAccountID:
                        errors.insert("\(NSLocalizedString("invalidAccountID", comment: "")) \(accID.stringRepresentation())")
                        break
                    default:
                        errors.insert(status.getErrorMessage())
                    }

                } catch {
                    if let err = error as? String {
                        errors.insert(err)
                    } else {
                        errors.insert(desc(error))
                    }
                    Logger.instance.log(message: desc(error), event: .i)
                }
            }
        }
        
        coreDataManager.saveContext()
        NotificationCenter.default.post(name: .onTransactionsUpdate, object: nil)
        
        if !errors.isEmpty {
            errorMessage = errors.joined(separator: "\n")
        }
    }
    
    private func fetchCost(_ payerAccount:HGCAccount, _ accID:HGCAccountID) throws -> UInt64 {
        let costRequest = APIRequestBuilder.getAccountRecordCostQuery(fromAccount: payerAccount, accountID: accID, node: node.accountID)
        Logger.instance.log(message: costRequest.textFormatString(), event: .i)
        do {
            let queryResponse = try cryptoClient.getAccountRecords(costRequest)
            Logger.instance.log(message: queryResponse.textFormatString(), event: .i)
            let status = queryResponse.cryptoGetAccountRecords.header.nodeTransactionPrecheckCode
            switch status {
            case .ok:
                return queryResponse.cryptoGetAccountRecords.header.cost
            case .payerAccountNotFound:
                throw "\(NSLocalizedString("payerAccountNotFound", comment: "")) \(payerAccount.accountID()!.stringRepresentation())"
            case .invalidAccountID:
                throw "\(NSLocalizedString("invalidAccountID", comment: "")) \(accID.stringRepresentation())"
            default:
                throw status.getErrorMessage()
            }
            
        } catch {
            Logger.instance.log(message: desc(error), event: .i)
            throw error
        }
    }
}
