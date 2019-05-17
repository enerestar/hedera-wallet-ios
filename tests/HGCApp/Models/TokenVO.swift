//
//  TokenVO.swift
//  HGCApp
//
//  Created by Surendra  on 13/08/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

struct TokenVO {
    let contractID: HGCAccountID
    let name: String
    let symbol: String
    let decimals: Int16
    init?(map:[String:Any]) {
        guard let idStr = map["contractID"] as? String,
            let accID = HGCAccountID.init(from: idStr),
            let name = map["name"] as? String,
            let symbol = map["symbol"] as? String,
            let decimals = map["decimals"] as? Int16 else {
                return nil
        }
        self.init(contractID:accID, name: name, symbol: symbol, decimals: decimals)
    }
    
    init(contractID:HGCAccountID, name:String, symbol:String, decimals:Int16) {
        self.contractID = contractID
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
    }
    
    func multiplier() -> Double {
        return pow(Double(10), Double(decimals))
    }
}
