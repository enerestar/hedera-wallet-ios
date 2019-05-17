//
//  Config.swift
//  HGCApp
//
//  Created by Surendra on 22/09/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import Foundation

let bundleInfo = Bundle.main.infoDictionary!
let appEnv = bundleInfo["HGCAPP_ENVIRONMENT"] as! String
let isDevMode = appEnv.uppercased().contains("DEVELOPMENT")
let allowEditingNet = true
let nodeListFileName = isDevMode ? "nodes-testnet.json" : "nodes-mainnet.json"
let feeScheduleFile = "feeScheduleproto.txt"
let loggingEnabled = true
let portalFAQRestoreAccount = "https://help.hedera.com/hc/en-us/articles/360000714658"
let useBetaAPIs = false // SignatureMap and bodyBytes
