//
//  WalletHelper.swift
//  HGCApp
//
//  Created by Surendra  on 24/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import Foundation
import Security

class WalletHelper: NSObject {
    public static let onboardDidSuccess = Notification.Name("onboardDidSuccess")
    
    static func keyChain() -> HGCKeyChainProtocol? {
        guard let wallet = HGCWallet.masterWallet(),
            let seed = SecureAppSettings.default.getSeed(),
            let option : SignatureOption = SignatureOption(rawValue: Int(wallet.signatureAlgorithm))  else {
            return nil
        }
        switch option {
        case .ED25519:
            return EDKeyChain.init(hgcSeed: HGCSeed.init(entropy: seed))
        case .ECDSA:
            return nil
        case .RSA:
            return nil
        }
    }
    
    static func syncData() {
        BalanceService.defaultService.updateBalances()
        TransactionService.defaultService.updateTransactions()
    }
    
    static func isOnboarded() -> Bool {
        return HGCWallet.masterWallet() != nil
    }

    static func onboard(signatureAlgorith:SignatureOption, seed:HGCSeed, accID:HGCAccountID? = nil) -> Bool {
        SecureAppSettings.default.setSeed(seed.entropy)
        HGCWallet.createMasterWallet(signatureAlgorith: Int16(signatureAlgorith.rawValue), accountID: accID)
        
        return true
    }
    
    static func confirmQuit() {
        Globals.showConfirmationAlert(title: NSLocalizedString("Confirm Quit?", comment: ""), message: NSLocalizedString("Are you sure you want to exit?", comment: ""), cancelButtonTitle:NSLocalizedString( "No", comment: ""), actionButtonTitle: NSLocalizedString("Yes", comment: ""), onConfirm: {
            quit()
        }, onDismiss: nil)
    }
    
    static func quit() {
        exit(0)
    }
}
