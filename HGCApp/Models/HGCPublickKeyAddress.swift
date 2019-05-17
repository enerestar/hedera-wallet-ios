//
//  HGCPublickKeyAddress.swift
//  HGCApp
//
//  Created by Surendra  on 18/07/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

struct HGCPublickKeyAddress {
    static let lengthEC = 97
    static let lengthED = 32
    static let lengthRSA = 613
    
    var publicKeyData:Data
    var type: SignatureOption
    
    static func extractData(data: Data) -> (type:SignatureOption?, data:Data?) {
        if let t = HGCPublickKeyAddress.getType(publicKeyData: data) {
            var length = 0
            switch t {
            case .ECDSA:
                length = HGCPublickKeyAddress.lengthEC
            case .ED25519:
                length = HGCPublickKeyAddress.lengthED
            case .RSA:
                length = HGCPublickKeyAddress.lengthRSA
            }
            if data.count == length  {
                return(t,data)
            }else {
                return (nil,nil)
            }
        } else {
            return (nil,nil)
        }
    }

    init?(publicKeyData:Data, type: SignatureOption) {
        if let data = HGCPublickKeyAddress.extractData(data: publicKeyData).data {
            self.publicKeyData = data
            self.type = type
        } else {
         return nil
        }
    }
    
    init?(data:Data) {
        let result = HGCPublickKeyAddress.extractData(data: data)
        if let d = result.data, let t = result.type  {
                self.type = t
                self.publicKeyData = d
        } else {
          return nil
        }
    }
    
    init?(publicKeyHex:String, type: SignatureOption) {
        if let data = publicKeyHex.hexadecimal() {
            self.publicKeyData = data
            self.type = type
        } else {
            return nil
        }
    }
    
    init?(hex:String) {
        if let data = hex.hexadecimal() {
            let result = HGCPublickKeyAddress.extractData(data: data)
            if let d = result.data, let t = result.type  {
                self.type = t
                self.publicKeyData = d
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    init?(from stringRepresentation:String?) {
        if let data = stringRepresentation?.hexadecimal()  {
            let result = HGCPublickKeyAddress.extractData(data: data)
            if let d = result.data, let t = result.type  {
                self.type = t
                self.publicKeyData = d
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func stringRepresentation() -> String {
        return self.publicKeyData.hex
    }
    
    static func getType(publicKeyData : Data) -> SignatureOption? {
        let length = publicKeyData.count
        switch length {
        case HGCPublickKeyAddress.lengthEC:
            return .ECDSA
        case HGCPublickKeyAddress.lengthED:
            return .ED25519
        case HGCPublickKeyAddress.lengthRSA:
            return .RSA
        default:
            return nil
        }
    }
}
