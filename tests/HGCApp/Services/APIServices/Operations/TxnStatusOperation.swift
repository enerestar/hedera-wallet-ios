//
//  TxnStatusOperation.swift
//  HGCApp
//
//  Created by Surendra on 14/04/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import Foundation

class TxnStatusOperation: BaseOperation {
    let txnID: Proto_TransactionID
    init(txnID: Proto_TransactionID) {
        self.txnID = txnID
    }
    
    override func main() {
        super.main()
        if let acc = HGCWallet.masterWallet()?.allAccounts().first {
            let receiptReq = APIRequestBuilder.requestForGetTxnReceipt(fromAccount: acc, paramTxnId: txnID, node: node.accountID)
            Logger.instance.log(message: receiptReq.textFormatString(), event: .i)
            
            do {
                let receiptRes = try cryptoClient.getTransactionReceipts(receiptReq)
                Logger.instance.log(message: receiptRes.textFormatString(), event: .i)
                
            } catch {
                Logger.instance.log(message: desc(error), event: .e)
            }
            
            
            let r = APIRequestBuilder.requestForGetTxnRecord(fromAccount: acc, paramTxnId: txnID, node: node.accountID)
            Logger.instance.log(message: r.textFormatString(), event: .i)
            
            do {
                let res = try cryptoClient.getFastTransactionRecord(r)
                Logger.instance.log(message: res.textFormatString(), event: .i)
                
            } catch {
                Logger.instance.log(message: desc(error), event: .e)
            }
            
        }
    }
}
