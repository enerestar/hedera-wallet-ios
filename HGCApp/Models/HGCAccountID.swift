//
//  HGCAccountID.swift
//  HGCApp
//
//  Created by Surendra  on 18/07/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

struct HGCAccountID : Comparable {
    var shardId: Int64
    var realmId : Int64
    var accountId : Int64

    init(shardId: Int64, realmId: Int64, accountId: Int64) {
        self.shardId = shardId
        self.realmId = realmId
        self.accountId = accountId
    }
    
    init?(from stringRepresentation:String?) {
        var shard: Int64?
        var realm : Int64?
        var account : Int64?
        if let items = stringRepresentation?.split(separator: ".") {
            if items.count == 3 {
                shard = Int64(items[0])
                realm = Int64(items[1])
                account = Int64(items[2])
            }
        }
        
        if  shard != nil && realm != nil && account != nil {
            self.shardId = shard!
            self.realmId = realm!
            self.accountId = account!
            
        } else {
            return nil
        }
    }
    
    func stringRepresentation() -> String {
        let items = [shardId.description,realmId.description,accountId.description]
        return items.joined(separator: ".")
    }
    
    static func < (lhs: HGCAccountID, rhs: HGCAccountID) -> Bool {
        return lhs.accountId == rhs.accountId && lhs.realmId == rhs.realmId && lhs.shardId == rhs.shardId
    }
}

extension Proto_AccountID {
    func hgcAccountID() -> HGCAccountID {
        return HGCAccountID.init(shardId: self.shardNum, realmId: self.realmNum, accountId: self.accountNum)
    }
}

extension Proto_ContractID {
    func hgcAccountID() -> HGCAccountID {
        return HGCAccountID.init(shardId: self.shardNum, realmId: self.realmNum, accountId: self.contractNum)
    }
}

