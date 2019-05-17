//
//  WalletView.swift
//  HGCApp
//
//  Created by Surendra  on 22/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

protocol WalletViewDelegate: class {
    func walletViewDidTapOnPay(_ walletView:WalletView)
    func walletViewDidTapOnRequest(_ walletView:WalletView)
}

class WalletView: UIViewController {
    @IBOutlet weak var coinBalanceLabel : UILabel!
    @IBOutlet weak var balanceLabel : UILabel!
    @IBOutlet weak var currencyLabel : UILabel!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView?
    @IBOutlet weak var lastUpdatedAt : UILabel!


    weak var delegate: WalletViewDelegate?
    
    var account : HGCAccount?
    
    static func getInstance(_ account:HGCAccount?) -> WalletView {
        let vc = Globals.mainStoryboard().instantiateViewController(withIdentifier: "walletView") as! WalletView
        vc.account = account
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAccountUpdate), name: .onAccountUpdate, object: nil)
        NotificationCenter.default.addObserver(forName: .onBalanceUpdate, object: nil, queue: OperationQueue.main) { (notif) in
            self.onAccountUpdate()
        }
        NotificationCenter.default.addObserver(forName: .onBalanceServiceStateChanged, object: nil, queue: OperationQueue.main) { (notif) in
            self.onAccountUpdate()
        }
        
        coinBalanceLabel.isUserInteractionEnabled = true
        coinBalanceLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(WalletView.onBalanceLableTap)))
        
        self.view.backgroundColor = Color.pageBackgroundColor()
        self.coinBalanceLabel.textColor = Color.primaryTextColor()
        self.coinBalanceLabel.font = Font.hgcAmountFontVeryBig()
        self.balanceLabel.textColor = Color.primaryTextColor()
        self.balanceLabel.font = Font.usdAmountFontVeryBig()
        self.currencyLabel.font = Font.regularFont(17.0)
        self.currencyLabel.text = kHGCCurrencySymbol
        self.lastUpdatedAt.textColor = Color.secondaryTextColor()
        self.lastUpdatedAt.font = Font.lightFontVerySmall()
        reloadUI()
    }
    
    private func reloadUI() {
        var nanoCoins : Int64!
        if let acc = account {
            nanoCoins = acc.balance
            
        } else {
            nanoCoins = HGCWallet.masterWallet()?.totalBalance() ?? 0
        }
        self.coinBalanceLabel.text = nanoCoins.toCoins().formatHGCShort()
        self.balanceLabel.text = CurrencyConverter.shared.convertTo$value(nanoCoins).format$()
        loadingIndicator?.isHidden = !BalanceService.defaultService.isRunning()
        if let date = account?.lastBalanceCheck {
            self.lastUpdatedAt.text = String(format: NSLocalizedString("LAST_UPDATED_", comment: ""), date.toString())
        } else {
            self.lastUpdatedAt.text = ""
        }
    }
    
    @objc private func onBalanceLableTap() {
        var nanoCoins : Int64!
        if let acc = account {
            nanoCoins = acc.balance
        } else {
            nanoCoins = HGCWallet.masterWallet()?.totalBalance() ?? 0
        }
        Globals.showGenericAlert(title: NSLocalizedString("HBAR", comment: ""), message: nanoCoins.toCoins().formatHGC())
    }
    
    @objc private func onAccountUpdate() {
        reloadUI()
    }
    
    @IBAction func onRequestButtonTap() {
        self.delegate?.walletViewDidTapOnRequest(self)
    }
    
    @IBAction func onPayButtonTap() {
        self.delegate?.walletViewDidTapOnPay(self)
    }
}
