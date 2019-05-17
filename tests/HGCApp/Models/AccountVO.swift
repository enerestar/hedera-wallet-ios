//
//  AccountVO.swift
//  HGCApp
//
//  Created by Surendra  on 11/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

struct AccountVO {
    var name : String?
    var address : HGCPublickKeyAddress?
    var accountID : HGCAccountID?

    init(address:HGCPublickKeyAddress, accountID:HGCAccountID? = nil, name:String? = nil) {
        self.address = address
        self.accountID = accountID
        self.name = name
    }
    
    init(accountID:HGCAccountID, address:HGCPublickKeyAddress? = nil, name:String? = nil) {
        self.accountID = accountID
        self.address = address
        self.name = name
    }
    
    init?(from stringRepresentation:String?, name: String? = nil) {
        if let accId = HGCAccountID.init(from: stringRepresentation) {
            self.accountID = accId
            self.name = name
        } else if let address = HGCPublickKeyAddress.init(from: stringRepresentation) {
            self.address = address
            self.name = name
        } else {
            return nil
        }
    }
    
    func stringRepresentation() -> String {
        if let acc = accountID {
            return acc.stringRepresentation()
        }
        return self.address!.stringRepresentation()
    }
}

class ContactVO {
    var name : String?
    var phone : String
    var email : String
    
    init(phone:String, name:String?) {
        self.phone = phone
        self.name = name
        self.email = ""
    }
    
    init(email:String, name:String?) {
        self.email = email
        self.name = name
        self.phone = ""
    }
}
