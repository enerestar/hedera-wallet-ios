//
//  TransactionVO.swift
//  HGCApp
//
//  Created by Surendra  on 24/07/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

enum ConsensusStatus {
    case unknown
    case success
    case failed
}

class TransactionVO {
    var txnID: String
    var createdDate: Date?
    var toAccountID: String?
    var fromAccountID: String?
    var feeCharged: UInt64 = 0
    var note: String? 
    var consensus: ConsensusStatus = .unknown
    
    private var amount: Int64?
    
    init?(_ txn:Proto_TransactionRecord) {
        txnID = txn.transactionID.stringRepresentation()
        feeCharged = txn.transactionFee
        note = txn.memo
        switch txn.receipt.status {
        case .unknown:
            consensus = .unknown
        case .success:
            consensus = .success
        default :
            consensus = .failed
        }
        if !txn.transferList.accountAmounts.isEmpty {
            for obj in txn.transferList.accountAmounts {
                if obj.amount > 0 {
                    toAccountID = obj.accountID.hgcAccountID().stringRepresentation()
                    amount = obj.amount
                } else {
                    fromAccountID = obj.accountID.hgcAccountID().stringRepresentation()
                }
            }
        } else {
            return nil
        }
    }
    
    init?(_ txn:Proto_Transaction) {
        let body = txn.transactionBody()
        txnID = body.transactionID.stringRepresentation()
        feeCharged = body.transactionFee
        note = body.memo
        if body.cryptoTransfer.hasTransfers {
            let list = body.cryptoTransfer.transfers
            for obj in list.accountAmounts {
                if obj.amount > 0 {
                    toAccountID = obj.accountID.hgcAccountID().stringRepresentation()
                    amount = obj.amount
                } else {
                    fromAccountID = obj.accountID.hgcAccountID().stringRepresentation()
                }
            }
        }
    }
    
    static func from(_ record: HGCRecord) -> TransactionVO? {
        var transactionVO:TransactionVO? = nil
        if let data = record.response {
            if let txn = try? Proto_TransactionRecord(serializedData: data), let vo = TransactionVO.init(txn) {
                transactionVO = vo
            }
            
        } else if let data = record.transaction {
            if let txn = try? Proto_Transaction(serializedData: data), let vo = TransactionVO.init(txn) {
                if let data = record.receipt {
                    if let response = try? Proto_Response(serializedData: data) {
                        if response.transactionGetReceipt.hasReceipt {
                            let receipt = response.transactionGetReceipt.receipt
                            switch receipt.status {
                            case .unknown:
                                break
                            case .success:
                                vo.consensus = .success
                            default:
                                vo.consensus = .failed
                            }
                        }
                    }
                }
                transactionVO = vo
            }
        }
        
        if transactionVO != nil {
            transactionVO?.createdDate = record.createdDate
        }
        
        return transactionVO
    }
    
    func isDebit() -> Bool {
        var isDebit = false
        for account in  HGCWallet.masterWallet()!.allAccounts() {
            if let accID = account.accountID() {
                if accID.stringRepresentation() == self.toAccountID {
                    isDebit = true
                    break
                }
            }
            
        }
        
        return isDebit
    }
    
    func displayAmount() -> UInt64 {
        return UInt64(amount ?? 0)
    }
}
