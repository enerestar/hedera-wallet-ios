//
//  CurrencyConverter.swift
//  HGCApp
//
//  Created by Surendra  on 28/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

let kHGCCurrencySymbol = "ℏ"

class CurrencyConverter: NSObject {
    static let shared : CurrencyConverter = CurrencyConverter();
    
    func convertToHGCNanoCoins(_ value$:Double) -> Int64 {
        return Double(value$/AppConfigService.defaultService.conversionRate()).toNanoCoins()
    }
    
    func convertToHGCCoins(_ value$:Double) -> Double {
        return Double(value$/AppConfigService.defaultService.conversionRate())
    }
    
    func convertTo$value(_ nanoCoins:Int64) -> Double {
        return Double(nanoCoins.toCoins() * AppConfigService.defaultService.conversionRate())
    }
    
    func convertTo$value(_ nanoCoins:UInt64) -> Double {
        return Double(nanoCoins.toCoins() * AppConfigService.defaultService.conversionRate())
    }
    
    func convertTo$value(coins:Double) -> Double {
        return Double(coins * AppConfigService.defaultService.conversionRate())
    }
}

extension Double {
    func format(toPlaces places:Int) -> String {
        let s = String(format: "%.\(places)f", self)
        return s;
    }
    
    func formatHGCShort(includeSymbol:Bool = false) -> String {
        return formatHGC(includeSymbol: includeSymbol, maximumFractionDigits:6)
    }
    
    func formatHGC(includeSymbol:Bool = false, maximumFractionDigits:Int = 8) -> String {
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = maximumFractionDigits > 8 ? maximumFractionDigits : 2
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.roundingMode = .halfUp
        formatter.decimalSeparator = "."
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        formatter.generatesDecimalNumbers = true
        let convertedPrice = formatter.string(from: self as NSNumber)
        return includeSymbol ? convertedPrice! + kHGCCurrencySymbol : convertedPrice!
        
    }
    
    func format$() -> String {
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        formatter.decimalSeparator = "."
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        formatter.generatesDecimalNumbers = true
        let convertedPrice = formatter.string(from: self as NSNumber)
        return "$"+convertedPrice!
    }
    
    func toNanoCoins() -> Int64 {
        return Int64((self * 100000000))
    }
}

extension Int64 {
    func toCoins() -> Double {
        return Double(self)/Double(100000000)
    }
}

extension UInt64 {
    func toCoins() -> Double {
        return Double(self)/Double(100000000)
    }
}
