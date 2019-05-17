//
//  ExportKeyParamsTest.swift
//  HGCAppTests
//
//  Created by Surendra on 16/11/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import XCTest
@testable import HGCApp

class PairingParamsTests: HGCAppTests {
    
    func testDataEncryption() {
        let params = PairingParams.init("7E892875A52C59A3B588306B13C31FBD7E892875A52C59A3B588306B13C31FBD\n168.192.0.1")!
        let data = try! JSONSerialization.data(withJSONObject: ["accountLabel":"Default Account","publicKey":"9a47731df70b20e1562addfce8c3cb30a4cf58d5a5cb1a8102648ba111fdd936"], options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let encryptedData = try! params.encrypt(data: data)
        //let base64 = encryptedData.base64EncodedString()
        //let map = ["data":base64]
        //let mapData = try! JSONSerialization.data(withJSONObject: map, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        //let s = String(data: mapData, encoding: .utf8)
        let decryptedData = try! params.decrypt(data: encryptedData)
        let createdMap = try! JSONSerialization.jsonObject(with: decryptedData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [String:String]
        XCTAssertTrue((createdMap["accountLabel"] != nil))
    }
    
    func testDataDecryption() {
        let str = "{\"data\":\"4hz1nRJA3nAlKdGKdTH1wlrIJjOZPwb0CRoe1cZktA3pxJcwLl82oF7\\/SP8A+dZXTfV5YYTgMP5ft3fDrvhU8vVseWUiFA8aouRcy3d4nFQjviZKmt4h8+rVDH0wXb6hBkfJLZOh7daSKbA0j4sabfUDpUpW5Es6i5cePoGuQtI2qXUCwFVFIvfujwE\\/KkIsFHajRxOuBIdD0FbjnG9CdCHGz0pmJGU77EtjxMNqFViU9k\\/1UHR+z1d9Th9WGAx7r1fYbXEEFyVYTC9M5jqwoQ2X1j87ttccODKe5A\\/fjGmA9pY5YgtT9+S6dcSDiK50oICVw3xB5Qy9VVJM3UY5QSDilAdiRHG1dpk1NVuSqxBF5CTf5qfJ4sTKDavgln2ygfCOpKxmWMKW0PoEPOxswxgcsic7Luj2EErgoqCvhiOZn9AahnJLOz52yO9ihDrwUCEm4zjKtHPC\",\"success\":true}"
        let mapData = str.data(using: .utf8)!
        let createdMap = try! JSONSerialization.jsonObject(with: mapData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [String:Any]
        let data = createdMap["data"] as! String
        let base64Data = Data.init(base64Encoded: data)
        
        let params = PairingParams.init("7E892875A52C59A3B588306B13C31FBD7E892875A52C59A3B588306B13C31FBD\n168.192.0.1")!
        let plain = try? params.decrypt(data: base64Data!)
        XCTAssertNotNil(plain)
    }
    
    func testGetPin() {
        let params = PairingParams.init("7E892875A52C59A3B588306B13C31FBD7E892875A52C59A3B588306B13C31FBD\n168.192.0.1")!
        XCTAssertTrue(params.getPIN("168.192.0.1") == "")
        XCTAssertTrue(params.getPIN("168.192.0.10") == "10")
        XCTAssertTrue(params.getPIN("168.192.10.10") == "10A10")
        XCTAssertTrue(params.getPIN("0.192.10.10") == "0A192A10A10")
    }

}
