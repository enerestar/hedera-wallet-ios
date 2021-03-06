//
//  HGCSeedTests.swift
//  HGCAppTests
//
//  Created by Surendra  on 11/05/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import XCTest
@testable import HGCApp

class HGCSeedTests: HGCAppTests {
    
    // Entropy
    func testSeedCreatedByEntropy() {
        let entropy = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb".hexadecimal()!
        let seed = HGCSeed.init(entropy: entropy)
        XCTAssertEqual(seed!.toWords().joined(separator: " "), "casual echo flesh tribal run react crunch cure pair sum skip fled castle floor crunch deputy run react castle fled cruise ethnic")
        XCTAssertEqual(seed!.toBIP39Words().joined(separator: " "), "primary taxi dance car case pelican priority kangaroo tackle math mimic matter primary fetch priority jazz slow another spell fetch primary fetch upon hip")
        
        XCTAssertTrue(seed!.entropy.count == 32)
        
        let mnemonic = Mnemonic.init(entropy: entropy)
        let words = mnemonic?.words
        
        let mnemonic1 = Mnemonic.init(words: words)
        let entropy1 = mnemonic1?.entropy
        XCTAssertEqual(entropy.toHexString(), entropy1?.toHexString())
        
    }
    
    func testSeedCreationFailsOnSmallerEntropy() {
        let entropy = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbb".hexadecimal()!
        let seed = HGCSeed.init(entropy: entropy)
        XCTAssertTrue(seed == nil)
    }
    
    func testSeedCreationFailsOnBiggerEntropy() {
        let entropy = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb2312".hexadecimal()!
        let seed = HGCSeed.init(entropy: entropy)
        XCTAssertTrue(seed == nil)
    }
    
    func testSeedCreationFailsOnEmptyEntropy() {
        let entropy = Data.init()
        let seed = HGCSeed.init(entropy: entropy)
        XCTAssertTrue(seed == nil)
    }
    
    // Words
    func testSeedCreatedByWords() {
        let words = ["casual","echo","flesh","tribal",
                     "run","react","crunch","cure",
                     "pair","sum","skip","fled",
                     "castle","floor","crunch","deputy",
                     "run","react","castle","fled",
                     "cruise","ethnic"]
        let seed = HGCSeed.init(words: words)
        XCTAssertEqual(seed?.entropy.hex, "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb");
        XCTAssert(seed!.entropy.count == 32)
    }
    
    func testSeedCreatedByBip39Words() {
        let words = "primary taxi dance car case pelican priority kangaroo tackle math mimic matter primary fetch priority jazz slow another spell fetch primary fetch upon hip".components(separatedBy: " ")
        let seed = HGCSeed.init(bip39Words: words)
        XCTAssertEqual(seed?.entropy.hex, "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb");
        XCTAssert(seed!.entropy.count == 32)
    }
    
    func testSeedCreationFalisOnInvalidWord() {
        // word "trademill" is not a valid word
        let words = ["casual","echo","flesh","tribal",
                     "trademill","react","crunch","cure",
                     "pair","sum","skip","fled",
                     "castle","floor","crunch","deputy",
                     "run","react","castle","fled",
                     "cruise","ethnic"]
        let seed = HGCSeed.init(words: words)
        XCTAssert(seed == nil)
    }
    
    func testSeedCreationFalisOnInvalidWordSequence() {
        // words are not in valid sequence
        let words = ["casual","echo","flesh","tribal",
                     "run","react","crunch","cure",
                     "pair","sum","skip","fled",
                     "castle","floor","crunch","deputy",
                     "run","react","castle","fled",
                     "cruise","run"]
        let seed = HGCSeed.init(words: words)
        XCTAssert(seed == nil)
    }
}
