
//
//  FeeBuilder.swift
//  HGCApp
//
//  Created by Surendra on 13/11/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

class FeeBuilder {
    let sizeLong:Int64 = 8
    let sizeInt:Int64 = 4
    let sizeBool:Int64 = 4
    
    func getCommonTransactionBodyBytes(_ body:Proto_TransactionBody) -> Int64 {
        /*
         * Common fields in all transaction
         
         *  TransactionID transactionID
         AccountID accountID  - 3 * LONG_SIZE bytes
         Timestamp transactionValidStart - (LONG_SIZE + INT_SIZE) bytes
         AccountID nodeAccountID  - 3 * LONG_SIZE bytes
         uint64 transactionFee  - LONG_SIZE bytes
         Duration transactionValidDuration - (LONG_SIZE + INT_SIZE) bytes
         bool generateRecord  - BOOL_SIZE bytes
         string memo  - get memo size from transaction
         *
         */
        
        var commonBytes:Int64 = 3 * sizeLong + (sizeLong + sizeInt)
        commonBytes = commonBytes + 3 * sizeLong + sizeLong + (sizeLong + sizeInt) + sizeBool
        commonBytes = commonBytes + Int64(body.memo.data(using: .utf8)!.count)
        return commonBytes
    }
    
    func getVPT(_ txn:Proto_Transaction) -> Int {
        // need to verify recursive depth of signatures
        var sig = Proto_Signature.init()
        sig.signatureList = txn.sigs
        return calculateNoOfSigs(sig: sig, count: 0)
    }
    
    private func calculateNoOfSigs(sig:Proto_Signature, count:Int) -> Int {
        var result = count
        if (!sig.signatureList.sigs.isEmpty) {
            for item in sig.signatureList.sigs {
                result = calculateNoOfSigs(sig: item, count: result)
            }
            
        } else if (!sig.thresholdSignature.sigs.sigs.isEmpty) {
            for item in sig.thresholdSignature.sigs.sigs {
                result = calculateNoOfSigs(sig: item, count: result)
            }
            
        } else {
            result = result + 1;
        }
        return result;
    }
}

class CryptoFeeBuilder: FeeBuilder {
    
    func getCryptoTransferTxFeeMatrics(_ txn:Proto_Transaction) -> Proto_FeeComponents {
        var bpt:Int64 = 0
        var vpt:Int64 = 0
        let rbs:Int64 = 0
        let sbs:Int64 = 0
        let gas:Int64 = 0
        var tv:Int64 = 0
        let bpr:Int64 = 0
        let sbpr:Int64 = 0
        
        var txnBodySize:Int64 = 0
        let body = txn.transactionBody()
        txnBodySize = getCommonTransactionBodyBytes(body)
        //bpt - Bytes per Transaction
        bpt = txnBodySize + getCryptoTransferBodyTxSize(body)
        
        //vpt - verifications per transactions
        vpt = Int64(getVPT(txn))
        
        //tv - Transfer Value
        tv = getTV(body)
        
        var feeMatricsForTx = Proto_FeeComponents.init()
        feeMatricsForTx.bpt = bpt
        feeMatricsForTx.vpt = vpt
        feeMatricsForTx.rbs = rbs
        feeMatricsForTx.sbs = sbs
        feeMatricsForTx.gas = gas
        feeMatricsForTx.tv = tv
        feeMatricsForTx.tv = tv
        feeMatricsForTx.bpr = bpr
        feeMatricsForTx.sbpr = sbpr
        return feeMatricsForTx
    }
    
    func getBalanceQueryFeeMatrics() -> Proto_FeeComponents {
        // get the Fee Matrics
        var bpt:Int64 = 0
        let vpt:Int64 = 0
        let rbs:Int64 = 0
        let sbs:Int64 = 0
        let gas:Int64 = 0
        let tv:Int64 = 0
        var bpr:Int64 = 0
        var sbpr:Int64 = 0
        
        /*
         *  CryptoGetAccountBalanceQuery
         *          QueryHeader
         *              Transaction - CryptoTransfer - (will be taken care in Transaction processing)
         *              ResponseType - INT_SIZE
         *          AccountID -  3 * LONG_SIZE
         */
        
        bpt = sizeInt + (3 * sizeLong);
        
        /*
         * CryptoGetAccountBalanceResponse
         * Response header
         * NodeTransactionPrecheckCode -  4 bytes
         * ResponseType - 4 bytes
         * AccountID - 24 bytes (consist of 3 long values)
         * balance - 8 bytes (1 long value)
         */
        
        bpr = sizeInt + sizeInt + 3 * sizeLong + sizeLong;
        
        /*
         * Account Balance Storage Size
         *
         * AccountID - 24 bytes (consist of 3 long values) balance - 8 bytes (1 long
         * value)
         */
        
        sbpr = 3 * sizeLong + sizeLong;
        
        var feeMatrix = Proto_FeeComponents.init()
        feeMatrix.bpt = bpt
        feeMatrix.vpt = vpt
        feeMatrix.rbs = rbs
        feeMatrix.sbs = sbs
        feeMatrix.gas = gas
        feeMatrix.tv = tv
        feeMatrix.tv = tv
        feeMatrix.bpr = bpr
        feeMatrix.sbpr = sbpr
        return feeMatrix
    }
    
    func  getCostTransactionRecordQueryFeeMatrics() -> Proto_FeeComponents {
        var bpt:Int64 = 0
        let vpt:Int64 = 0
        let rbs:Int64 = 0
        let sbs:Int64 = 0
        let gas:Int64 = 0
        let tv:Int64 = 0
        var bpr:Int64 = 0
        let sbpr:Int64 = 0
        
        /*
         *  CostTransactionGetRecordQuery
         *          QueryHeader
         *              Transaction - CryptoTransfer - (will be taken care in Transaction processing)
         *              ResponseType - INT_SIZE
         *          TransactionID
         *              AccountID accountID  - 3 * LONG_SIZE bytes
         Timestamp transactionValidStart - (LONG_SIZE + INT_SIZE) bytes
         */
        
        bpt = sizeInt + (3 * sizeLong) + (sizeLong + sizeInt);
        
        /*
         * Response header
         * NodeTransactionPrecheckCode -  4 bytes
         * ResponseType - 4 bytes
         * uint64 cost - 8 bytes
         */
        bpr = sizeInt + sizeInt + sizeLong;
    
    
        var feeMatrix = Proto_FeeComponents.init()
        feeMatrix.bpt = bpt
        feeMatrix.vpt = vpt
        feeMatrix.rbs = rbs
        feeMatrix.sbs = sbs
        feeMatrix.gas = gas
        feeMatrix.tv = tv
        feeMatrix.tv = tv
        feeMatrix.bpr = bpr
        feeMatrix.sbpr = sbpr
        return feeMatrix
    }
    
    private func getCryptoTransferBodyTxSize(_ body:Proto_TransactionBody) -> Int64 {
        /*
         * TransferList transfers
         repeated AccountAmount
         AccountID - (3 * LONG_SIZE)
         sint64 amount - LONG_SIZE
         */
    
        let accountAmountCount:Int64 = Int64(body.cryptoTransfer.transfers.accountAmounts.count);
        let cryptoTransfertBodySize = ((3 * sizeLong) + sizeLong) * accountAmountCount;
        return cryptoTransfertBodySize;
    }
    
    private func getTV(_ body:Proto_TransactionBody) -> Int64 {
        var amount:Int64 = 0
        for actAmt in body.cryptoTransfer.transfers.accountAmounts {
            if actAmt.amount > 0 {
                amount = amount + actAmt.amount
            }
        }
        return Int64(amount/1000)
    }
    
}

class FeeComponentBuilder {
    
    public func getComponentFee(componentCoefficients:Proto_FeeComponents , componentMetrics:Proto_FeeComponents) -> Int64 {
        let bytesUsageFee = componentCoefficients.bpt * componentMetrics.bpt
        let verificationFee = componentCoefficients.vpt * componentMetrics.vpt
        let ramStorageFee = componentCoefficients.rbs * componentMetrics.rbs
        let storageFee = componentCoefficients.sbs * componentMetrics.sbs
        let evmGasFee = componentCoefficients.gas * componentMetrics.gas
        let txValueFee = (componentCoefficients.tv * componentMetrics.tv) / 1000
        let bytesResponseFee = componentCoefficients.bpr * componentMetrics.bpr
        let storageBytesResponseFee = componentCoefficients.sbpr * componentMetrics.sbpr
        
        var totalComponentFee = componentCoefficients.constant +
            (bytesUsageFee + verificationFee + ramStorageFee + storageFee + evmGasFee + txValueFee + bytesResponseFee +  storageBytesResponseFee)
        
        if(totalComponentFee < componentCoefficients.min) {
            totalComponentFee = componentCoefficients.min
        } else if(totalComponentFee > componentCoefficients.max) {
            totalComponentFee = componentCoefficients.max
        }
        return totalComponentFee
    }
    
    func getTotalFeeforRequest(feeCoefficients:Proto_FeeData, componentMetrics:Proto_FeeComponents) -> Int64 {
        // get Node Fee
        let nodeFee = getComponentFee(componentCoefficients: feeCoefficients.nodedata, componentMetrics: componentMetrics)
        
        // get Network fee
        let  networkFee =  getComponentFee(componentCoefficients: feeCoefficients.networkdata, componentMetrics: componentMetrics)
        //System.out.println("The networkFee Fee is "+networkFee);
        // get Service Fee
        let  serviceFee =  getComponentFee(componentCoefficients: feeCoefficients.servicedata, componentMetrics: componentMetrics)
        //System.out.println("The serviceFee Fee is "+serviceFee);
        
        let totalFee = nodeFee + networkFee + serviceFee
        return totalFee
    }
}
