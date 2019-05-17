//
//  HAPI+HGCPublickKeyAddress.swift
//  HGCApp
//
//  Created by Surendra on 15/04/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import Foundation

extension HGCPublickKeyAddress {
    func protoKey() -> Proto_Key {
        var key = Proto_Key.init()
        switch self.type {
        case .ECDSA:
            key.ecdsa384 = self.publicKeyData
        case .ED25519:
            key.ed25519 = self.publicKeyData
        case .RSA:
            key.rsa3072 = self.publicKeyData
        }
        return key
    }
}
