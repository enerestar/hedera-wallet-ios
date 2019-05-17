//
//  APIRequestBuilder.swift
//  HGCApp
//
//  Created by Surendra  on 12/07/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftProtobuf

class APIRequestBuilder {
    static let placeholderFee : UInt64 = 0
    
    static func getFeeSch() -> [Proto_HederaFunctionality:Proto_FeeData] {
        let data = try! Data.init(contentsOf: Bundle.main.url(forResource: feeScheduleFile, withExtension: "")!)
        let feeSch = try! Proto_FeeSchedule(serializedData: data)
        var map = [Proto_HederaFunctionality:Proto_FeeData]()
        for item in feeSch.transactionFeeSchedule {
            map[item.hederaFunctionality] = item.feeData
        }
        return map
    }
    
    static func requestForTransfer(fromAccount:HGCAccount, toAccount:HGCAccountID, amount:UInt64, notes:String?, node:HGCAccountID = HGCAccountID.init(shardId: 0, realmId: 0, accountId: 0), fee:UInt64) -> Proto_Transaction {
        
        var payerAccount = Proto_AccountID.init()
        if let acc = fromAccount.accountID() {
            payerAccount = acc.protoAccountID()
        }
        
        var txnBody = fromAccount.txnBody(memo: notes, node: node.protoAccountID(), fee: fee, generateRecord: true)
        txnBody.cryptoTransfer = Proto_CryptoTransferTransactionBody.body(from: payerAccount, to: toAccount.protoAccountID(), amount: amount)
        
        let txn = fromAccount.signedTransaction(body: txnBody, dummy: node.stringRepresentation() == "0.0.0")
        
        return txn
    }
    
    
    static func feeForTransfer(_ txn:Proto_Transaction) -> UInt64 {
        let feeData = getFeeSch()[Proto_HederaFunctionality.cryptoTransfer]!
        let crBuilder = CryptoFeeBuilder.init()
        let feeMatrics = crBuilder.getCryptoTransferTxFeeMatrics(txn)
        let fee = FeeComponentBuilder.init().getTotalFeeforRequest(feeCoefficients: feeData, componentMetrics: feeMatrics)
        return UInt64(fee)
    }
    
    static func requestForGetTxnReceipt(fromAccount:HGCAccount, paramTxnId:Proto_TransactionID, node:HGCAccountID) -> Proto_Query {
        let qHeader = fromAccount.createQueryHeader(node: node, memo: "for receipt", includePayment: false, fee: 0)
        var txnGetReceiptQuery = Proto_TransactionGetReceiptQuery.init()
        txnGetReceiptQuery.header = qHeader
        txnGetReceiptQuery.transactionID = paramTxnId
        var query = Proto_Query.init()
        query.transactionGetReceipt = txnGetReceiptQuery
        return query
    }
    
    static func requestForGetTxnRecord(fromAccount:HGCAccount, paramTxnId:Proto_TransactionID, node:HGCAccountID) -> Proto_Query {
        let qHeader = fromAccount.createQueryHeader(node: node, memo: "for txn record", fee:0)
        var txnGetRecordQuery = Proto_TransactionGetRecordQuery.init()
        txnGetRecordQuery.header = qHeader
        txnGetRecordQuery.transactionID = paramTxnId
        var query = Proto_Query.init()
        query.transactionGetRecord = txnGetRecordQuery
        return query
    }
    
    static func getBalanceQuery(fromAccount:HGCAccount, accountID:HGCAccountID, node:HGCAccountID) -> Proto_Query {
        let qHeader = fromAccount.createQueryHeader(node: node, memo: "for balance check", fee:feeForGetBalance())
        var getBalaceQuery = Proto_CryptoGetAccountBalanceQuery.init()
        getBalaceQuery.header = qHeader
        getBalaceQuery.accountID = accountID.protoAccountID()
        var query = Proto_Query.init()
        query.cryptogetAccountBalance = getBalaceQuery
        return query
    }
    
    static func feeForGetBalance() -> UInt64 {
        let feeData = getFeeSch()[Proto_HederaFunctionality.cryptoGetAccountBalance]!
        let crBuilder = CryptoFeeBuilder.init()
        let feeMatrics = crBuilder.getBalanceQueryFeeMatrics()
        let fee = FeeComponentBuilder.init().getTotalFeeforRequest(feeCoefficients: feeData, componentMetrics: feeMatrics)
        return UInt64(fee)
    }
    
    static func getAccountRecordQuery(fromAccount:HGCAccount, accountID:HGCAccountID, node:HGCAccountID, fee:UInt64) -> Proto_Query {
        let qHeader = fromAccount.createQueryHeader(node: node, memo: "for account record", fee:fee)
        var accRecordQuery = Proto_CryptoGetAccountRecordsQuery.init()
        accRecordQuery.header = qHeader
        accRecordQuery.accountID = accountID.protoAccountID()
        var query = Proto_Query.init()
        query.cryptoGetAccountRecords = accRecordQuery
        return query
    }
    
    static func getAccountRecordCostQuery(fromAccount:HGCAccount, accountID:HGCAccountID, node:HGCAccountID) -> Proto_Query {
        let qHeader = fromAccount.createQueryHeader(node: node, memo: "for account record cost", fee:feeForgetAccountRecordCost(), rType:.costAnswer)
        var accRecordQuery = Proto_CryptoGetAccountRecordsQuery.init()
        accRecordQuery.header = qHeader
        accRecordQuery.accountID = accountID.protoAccountID()
        var query = Proto_Query.init()
        query.cryptoGetAccountRecords = accRecordQuery
        return query
    }
    
    static func feeForgetAccountRecordCost() -> UInt64 {
        let feeData = getFeeSch()[Proto_HederaFunctionality.cryptoGetAccountRecords]!
        let crBuilder = CryptoFeeBuilder.init()
        let feeMatrics = crBuilder.getCostTransactionRecordQueryFeeMatrics()
        let fee = FeeComponentBuilder.init().getTotalFeeforRequest(feeCoefficients: feeData, componentMetrics: feeMatrics)
        return UInt64(fee)
    }
    
    static func requestForGetAccountInfo(fromAccount:HGCAccount, accountID:HGCAccountID, node:HGCAccountID) -> Proto_Query {
        var getInfoQuery = Proto_CryptoGetInfoQuery.init()
        getInfoQuery.header = fromAccount.createQueryHeader(node: node, memo: "for get account info", fee:0)
        getInfoQuery.accountID = accountID.protoAccountID()
        var query = Proto_Query.init()
        query.cryptoGetInfo = getInfoQuery
        return query
    }
    
}

extension Proto_CryptoTransferTransactionBody {
    static func body(from: Proto_AccountID, to: Proto_AccountID, amount:UInt64) -> Proto_CryptoTransferTransactionBody {
        var accAmount1 = Proto_AccountAmount.init()
        accAmount1.accountID = from
        accAmount1.amount = -1 * Int64(amount)
        
        var accAmount2 = Proto_AccountAmount.init()
        accAmount2.accountID = to
        accAmount2.amount = Int64(amount)
        
        var list = Proto_TransferList.init()
        list.accountAmounts = [accAmount1, accAmount2]
        
        var body = Proto_CryptoTransferTransactionBody.init()
        body.transfers = list
        return body
    }
}

extension Proto_Transaction {
    func transactionBody() -> Proto_TransactionBody {
        do {
            if !bodyBytes.isEmpty {
                return try Proto_TransactionBody(serializedData: bodyBytes)
            }
            
        } catch {
           
        }
         return body
    }
}

