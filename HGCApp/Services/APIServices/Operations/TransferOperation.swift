//
//  TransferOperation.swift
//  HGCApp
//
//  Created by Surendra  on 24/08/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import Foundation

class TransferOperation: BaseOperation {
    let fromAccount: HGCAccount
    let toAccount: HGCAccountID
    let toAccountName: String?
    let amount:UInt64
    let notes:String?
    let fee:UInt64
    
    init(fromAccount:HGCAccount, toAccount:HGCAccountID, toAccountName:String?, amount:UInt64, notes:String?, fee:UInt64) {
        self.fromAccount = fromAccount
        self.toAccount = toAccount
        self.toAccountName = toAccountName
        self.amount = amount
        self.notes = notes
        self.fee = fee
    }
    
    override func main() {
        super.main()
        let r = APIRequestBuilder.requestForTransfer(fromAccount: self.fromAccount, toAccount: toAccount, amount: self.amount, notes: self.notes, node: node.accountID, fee: fee)
        Logger.instance.log(message: r.textFormatString(), event: .i)
        do {
            let response = try cryptoClient.cryptoTransfer(r)
            Logger.instance.log(message: response.textFormatString(), event: .i)
            switch response.nodeTransactionPrecheckCode {
            case .ok:
                let savedTxn = self.saveTransaction(txn:r)
                sleep(1)
                var isSuccess = false
                for _ in 1...3 {
                    let receiptReq = APIRequestBuilder.requestForGetTxnReceipt(fromAccount: self.fromAccount, paramTxnId: r.transactionBody().transactionID, node: node.accountID)
                    Logger.instance.log(message: receiptReq.textFormatString(), event: .i)
                    
                    do {
                        let receiptRes = try cryptoClient.getTransactionReceipts(receiptReq)
                        Logger.instance.log(message: receiptRes.textFormatString(), event: .i)
                        if receiptRes.transactionGetReceipt.hasReceipt {
                            switch receiptRes.transactionGetReceipt.receipt.status {
                            case .unknown:
                                self.errorMessage = "Unable to fetch receipt, status unknown"
                                break
                            case .success:
                                isSuccess = true
                            default:
                                self.errorMessage = receiptRes.transactionGetReceipt.receipt.status.getErrorMessage()
                            }
                        }
                        savedTxn.receipt = try? receiptRes.serializedData()
                        
                    } catch {
                        Logger.instance.log(message: desc(error), event: .e)
                        errorMessage = desc(error)
                        break
                    }
                    if isSuccess {
                        self.errorMessage = nil
                        break
                    }
                    sleep(2)
                }
                
            default:
                self.errorMessage = response.nodeTransactionPrecheckCode.getErrorMessage()
            }
            
        } catch {
            Logger.instance.log(message: desc(error), event: .e)
            errorMessage  = desc(error)
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func saveTransaction(txn: Proto_Transaction) -> HGCRecord {
        let record = self.fromAccount.createTransaction(toAccountID: self.toAccount, txn:txn)
        HGCContact.addAlias(name: self.toAccountName, address: self.toAccount.stringRepresentation())
        return record
    }
}
