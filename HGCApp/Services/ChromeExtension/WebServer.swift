//
//  WebServer.swift
//  HGCApp
//
//  Created by Surendra on 28/10/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit
import GCDWebServer
import CryptoSwift

protocol WebServerProtocol : class {
    func log(value:String)
    func getAccount() -> HGCAccount?
    func requestHandled()
}

struct PairingParams {
    let key:Data // AES256 key
    let ip:String // Extension's IP
    
    init?(_ qrCode:String) {
        let items = qrCode.components(separatedBy: "\n")
        if items.count >= 2, let keyData = items[0].hexadecimal(), keyData.count == 32, items[1].components(separatedBy: ".").count == 4 {
            self.key = keyData
            self.ip = items[1]
            
        } else {
            return nil
        }
    }
    
    func encrypt(data:Data) throws -> Data {
        let digest = data.sha384()
        var fullMessage = data
        fullMessage.append(digest)
        let aes = try AES.init(key: Array(key), blockMode: CTR.init(iv: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]), padding: .noPadding)
        let ciphertext = try aes.encrypt(Array(fullMessage))
        /*
        let de = try aes.decrypt(Array(ciphertext))
        let plainF = Data.init(bytes: de)
        let plain = plainF.prefix(plainF.count-48)
        let str = String(data: plain, encoding: .utf8)
        */
        return Data.init(bytes: ciphertext)
    }
    
    func decrypt(data:Data) throws -> Data {
        let aes = try AES.init(key: Array(key), blockMode: CTR.init(iv: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]), padding: .noPadding)
         let de = try aes.decrypt(Array(data))
         let plainF = Data.init(bytes: de)
         let plain = plainF.prefix(plainF.count-48)
         //let str = String(data: plain, encoding: .utf8)
        return plain
    }
    
    func getPIN(_ myIp:String) -> String {
        var items = [String]()
        let ip1 = ip.components(separatedBy: ".")
        let ip2 = myIp.components(separatedBy: ".")
        
        for index in 0...3 {
            if ip1[index] != ip2[index] {
                items.append(contentsOf: ip2[index...3])
                break
            }
        }
        return items.joined(separator: "A")
    }
}

class WebServer : NSObject {
    weak var delegate:WebServerProtocol?
    let webServer = GCDWebServer()
    let port:UInt = 8080
    let params: PairingParams
    init(params:PairingParams) {
        self.params = params
        super.init()
        
        webServer.addHandler(forMethod: "OPTIONS", path:"/", request: GCDWebServerRequest.self, processBlock:{ req in
            let resp = GCDWebServerResponse()
            resp.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            resp.setValue("PUT,POST,GET,PATCH,DELETE", forAdditionalHeader: "Access-Control-Allow-Methods")
            resp.setValue("true", forAdditionalHeader: "Access-Control-Allow-Credentials")
            return resp
        })
        
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {[weak self] request in
            self?.log(value: request.description)
            var response: GCDWebServerDataResponse?
            var errorMsg:String = ""
            if let accData = self?.delegate?.getAccount()?.toJSONData(includePrivateKey: true) {
                do {
                    let data = try self?.params.encrypt(data: accData) ?? Data.init()
                    self?.delegate?.requestHandled()
                    response = GCDWebServerDataResponse.init(jsonObject: ["success":true, "data":data.base64EncodedString()])
                    
                } catch {
                    errorMsg = "Failed to encrypt the data"
                }
                
            } else {
                errorMsg = "No Account is selected"
            }
            if response == nil {
                response = GCDWebServerDataResponse.init(jsonObject: ["error":errorMsg])
            }
            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
            response?.setValue("PUT,POST,GET,PATCH,DELETE", forAdditionalHeader: "Access-Control-Allow-Methods")
            response?.setValue("true", forAdditionalHeader: "Access-Control-Allow-Credentials")
            return response
        })
    }
    
    func getPIN() -> String {
        return params.getPIN(IPUtility.getMyIP().ip!)
    }
    
    func startServer() {
        webServer.delegate = self
        webServer.start(withPort: port, bonjourName: "HGC mobile app Web Server")
    }
    
    func stopServer() {
        webServer.stop()
    }
    
    func getServerURL() -> URL? {
        return webServer.serverURL
    }
    
    private func log(value:String) {
        print(value)
        DispatchQueue.main.async {
            self.delegate?.log(value: value)
        }
    }
    
}

extension WebServer : GCDWebServerDelegate {
    func webServerDidStart(_ server: GCDWebServer) {
        log(value: "webServerDidStart")
        log(value: "Visit \(webServer.serverURL!.absoluteString) in your web browser")
    }
    
    func webServerDidConnect(_ server: GCDWebServer) {
        log(value: "webServerDidConnect")
    }
    
    func webServerDidDisconnect(_ server: GCDWebServer) {
        log(value: "webServerDidDisconnect")
    }
    
    func webServerDidStop(_ server: GCDWebServer) {
        log(value: "webServerDidStop")
    }
}
