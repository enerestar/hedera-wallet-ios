//
//  EDKeyChainTests.swift
//  HGCAppTests
//
//  Created by Surendra  on 11/05/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import XCTest
@testable import HGCApp

class EDKeyChainTests: HGCAppTests {
    
    var keyChain : EDKeyChain? {
        get {
            let seed = HGCSeed.init(entropy: "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb".hexadecimal()! as Data)
            return EDKeyChain.init(hgcSeed: seed!)
        }
    }
    
    func testKeyChainCreation() {
        XCTAssert(self.keyChain != nil)
    }
    
    func testChileKeyCreation() {
        let key0 = keyChain!.key(at: 0)
        XCTAssert(key0 != nil)
        print(key0!.publicKeyData.hex)
        let key1 = keyChain?.key(at: 1)
        XCTAssert(key1 != nil)
        print(key1!.publicKeyData.hex)
    }
    
}
