//
//  HAPI+HGCAccountID.swift
//  HGCApp
//
//  Created by Surendra on 15/04/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import Foundation

extension HGCAccountID {
    func protoAccountID() -> Proto_AccountID {
        var acc = Proto_AccountID.init()
        acc.accountNum = accountId
        acc.realmNum = realmId
        acc.shardNum = shardId
        return acc
    }
    
    func protoContractID() -> Proto_ContractID {
        var acc = Proto_ContractID.init()
        acc.contractNum = accountId
        acc.realmNum = realmId
        acc.shardNum = shardId
        return acc
    }
}
