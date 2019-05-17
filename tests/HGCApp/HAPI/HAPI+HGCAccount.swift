//
//  HAPI+HGCAccount.swift
//  HGCApp
//
//  Created by Surendra on 15/04/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import Foundation

extension HGCAccount {
    func txnBody(memo:String?, node:Proto_AccountID, fee:UInt64, generateRecord:Bool = false) -> Proto_TransactionBody {
        var txnId = Proto_TransactionID.init()
        var payerAccount = Proto_AccountID.init()
        if let acc = self.accountID() {
            payerAccount = acc.protoAccountID()
        }
        txnId.transactionValidStart = Date().timeIntervalSince1970.protoTimestamp()
        txnId.accountID = payerAccount
        
        var txnBody = Proto_TransactionBody.init()
        txnBody.transactionID = txnId
        txnBody.transactionFee = fee
        txnBody.transactionValidDuration = TimeInterval(30).protoDuration()
        txnBody.generateRecord = generateRecord
        txnBody.memo = memo ?? ""
        txnBody.nodeAccountID = node
        return txnBody
    }
    
    func signedTransaction(body:Proto_TransactionBody, dummy:Bool = false) -> Proto_Transaction {
        if useBetaAPIs {
            var sigMap = Proto_SignatureMap.init()
            sigMap.sigPair = [getSignaturePair(body: body, dummy: dummy)]
            
            var txn = Proto_Transaction.init()
            txn.bodyBytes = try! body.serializedData()
            txn.sigMap = sigMap
            return txn
            
        } else {
            var list = Proto_SignatureList.init()
            list.sigs = [getSignature(body: body, dummy: dummy), getSignature(body: body, dummy: dummy)]
            var txn = Proto_Transaction.init()
            txn.body = body
            txn.sigs = list
            return txn
        }
        
    }
    
    private func getSignaturePair(body:Proto_TransactionBody, dummy:Bool) -> Proto_SignaturePair {
        
        var signature = Proto_SignaturePair.init()
        if let serializedData = try? body.serializedData() {
            let sig = dummy ? Data.init() : sign(serializedData)
            
            switch self.wallet!.signatureOption() {
            case .ECDSA:
                signature.ecdsa384 = sig
            case .ED25519:
                signature.ed25519 = sig
            case .RSA:
                signature.rsa3072 = sig
            }
        }
        
        let data = publicKey!
        var values = [UInt8](repeating:0, count:4)
        data.copyBytes(to: &values, count: 4)
        signature.pubKeyPrefix = Data.init(values)
        return signature
    }
    
    private func getSignature(body:Proto_TransactionBody, dummy:Bool) -> Proto_Signature {
        var signature = Proto_Signature.init()
        if let serializedData = try? body.serializedData() {
            let sig = dummy ? Data.init() : sign(serializedData)
            switch self.wallet!.signatureOption() {
            case .ECDSA:
                signature.ecdsa384 = sig
            case .ED25519:
                signature.ed25519 = sig
            case .RSA:
                signature.rsa3072 = sig
            }
        }
        
        return signature
    }
    
    
    func createQueryHeader(node:HGCAccountID, memo:String, includePayment:Bool = true, fee:UInt64, rType:Proto_ResponseType = .answerOnly) -> Proto_QueryHeader {
        var payerAccount = Proto_AccountID.init()
        if let acc = accountID() {
            payerAccount = acc.protoAccountID()
        }
        
        let nodeAccount = node.protoAccountID()
        
        var placeholderBody = txnBody(memo: memo, node: nodeAccount, fee: APIRequestBuilder.placeholderFee)
        placeholderBody.cryptoTransfer = Proto_CryptoTransferTransactionBody.body(from: payerAccount, to: nodeAccount, amount: fee)
        let placeholderTxn = signedTransaction(body: placeholderBody, dummy: true)
        let transactionFee = APIRequestBuilder.feeForTransfer(placeholderTxn)
        
        var body = txnBody(memo: memo, node: nodeAccount, fee: transactionFee)
        body.cryptoTransfer = Proto_CryptoTransferTransactionBody.body(from: payerAccount, to: nodeAccount, amount: fee)
        let txn = signedTransaction(body: body)
        var qHeader = Proto_QueryHeader.init()
        if includePayment {
            qHeader.payment = txn
        }
        qHeader.responseType = rType
        return qHeader
    }
}
