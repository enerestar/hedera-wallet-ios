//
//  AppConfigService.swift
//  HGCApp
//
//  Created by Surendra  on 29/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class AppConfigService {
    static let defaultService : AppConfigService = AppConfigService();    
    
    
    func transferFee() -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: "transferFee"))
    }
    
    private func setTransferFee(_ fee:Int64) {
        UserDefaults.standard.set(fee, forKey: "transferFee")
        UserDefaults.standard.synchronize()
    }
    
    func balanceCheckFee() -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: "balanceCheckFee"))
    }
    
    private func setBalanceCkeckFee(_ fee:Int64) {
        UserDefaults.standard.set(fee, forKey: "balanceCheckFee")
        UserDefaults.standard.synchronize()
    }
    
    func txnHistoryFee() -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: "txnHistoryFee"))
    }
    
    private func setTxnHistoryFeeFee(_ fee:Int64) {
        UserDefaults.standard.set(fee, forKey: "txnHistoryFee")
        UserDefaults.standard.synchronize()
    }
    
    func conversionRate() -> Double {
        return 0.12
        //return UserDefaults.standard.double(forKey:"conversionRate")
    }
    
    private func setconversionRate(_ rate:Double) {
        UserDefaults.standard.set(rate, forKey: "conversionRate")
        UserDefaults.standard.synchronize()
    }
    
//    func serviceFee() -> Int64 {
//        return 50
//    }
//    
//    func nodeFee() -> Int64 {
//        return 50
//    }
//    
//    func loadConfig() {
//        self.loadFeeSchedule()
//    }
//    
//    private func loadFeeSchedule() {
//        
//    }
}
