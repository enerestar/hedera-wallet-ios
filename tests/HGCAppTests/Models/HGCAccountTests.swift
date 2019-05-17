//
//  HGCAccountTests.swift
//  HGCAppTests
//
//  Created by Surendra  on 25/05/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import XCTest
@testable import HGCApp

class HGCAccountTests: HGCAppTests {
    
//    static func createATestAccount (_ coreDataManager: MockCoreDataManager) {
//        let entropy = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc".hexadecimal()!
//        let seed = HGCSeed.init(entropy: entropy)!
//        SecureAppSettings.default.setSeed(seed.data)
//        HGCWallet.createMasterWallet(signatureAlgorith: Int16(SignatureOption.ED25519.rawValue), coreDataManager: coreDataManager)
//    }
//    
//    func testAccount() {
//        let coreDataManager = MockCoreDataManager.init()
//        HGCAccountTests.createATestAccount(coreDataManager)
//        let wallet = HGCWallet.masterWallet(coreDataManager.mainContext)!
//        let account = wallet.accounts?.anyObject() as! HGCAccount
//        XCTAssert(account.publicKeyString().count > 20)
//        XCTAssert(account.privateKeyString().count > 20)
//        
//        account.createTransaction(toAddress: "0x34a342aacc22", toName: "testToName", amount: 100, requestId: "100",coreDataManager)
//        account.createTransaction(toAddress: "0x34a342aacc22", toName: "testToName", amount: 100, requestId: "101",coreDataManager)
//        XCTAssertEqual(account.getAllTxn(context:coreDataManager.mainContext).count, 2)
//        
//        SecureAppSettings.default.clearSeed()
//    }
}
