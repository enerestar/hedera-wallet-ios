//
//  PayViewController.swift
//  HGCApp
//
//  Created by Surendra  on 24/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import MBProgressHUD

class PayViewController: UITableViewController {
    
    private static let rowIndexFrom = 0
    private static let rowIndexTo = 1
    private static let rowIndexAmount = 2
    private static let rowIndexOptions = 3
    private static let rowIndexFee = 4
    private static let rowIndexNotes = 5
    private static let rowIndexPay = 6
    
    //@IBOutlet weak var tableView : UITableView!
    var qrCell : QRScanTableCell?
    
    var fromAccount : HGCAccount?
    var toAccount : AccountVO?
    var token : SCToken?
    var selfMode : Bool = false
    var gas : UInt64 = 500000
    var fee : UInt64 = 0
    var amount : Int64? = 0
    var isQROptionSelected = false
    var hasNotes = false
    var notes : String = ""
    var notifRequested = false
    var isNewSelected = false
    
    var request : HGCRequest?
    var queue = OperationQueue.init()
    
    static func getInstance() -> PayViewController {
        return PayViewController.init(style: .plain)//Globals.mainStoryboard().instantiateViewController(withIdentifier: "payViewController") as! PayViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.title = token != nil ? NSLocalizedString("TRANSFER", comment: "") : NSLocalizedString("PAY", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon-close"), style: .plain, target: self, action: #selector(onCloseButtonTap))
        self.tableView.register(UINib.init(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "accountAddressTableCell")
        self.tableView.register(UINib.init(nibName: "AddressOptionsTableCell", bundle: nil), forCellReuseIdentifier: "AddressOptionsTableCell")
        self.tableView.register(UINib.init(nibName: "AmountTableViewCell", bundle: nil), forCellReuseIdentifier: "AmountTableViewCell")
        self.tableView.register(UINib.init(nibName: "QRScanTableCell", bundle: nil), forCellReuseIdentifier: "QRScanTableCell")
        self.tableView.register(UINib.init(nibName: "ActionButtonTableCell", bundle: nil), forCellReuseIdentifier: "ActionButtonTableCell")
        self.tableView.register(UINib.init(nibName: "TXNOptionsTableCell", bundle: nil), forCellReuseIdentifier: "TXNOptionsTableCell")
        self.tableView.register(UINib.init(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NotesTableViewCell")
        self.tableView.register(UINib.init(nibName: "FeeTableCell", bundle: nil), forCellReuseIdentifier: "FeeTableCell")
         self.tableView.register(UINib.init(nibName: "MyAddressTableCell", bundle: nil), forCellReuseIdentifier: "MyAddressTableCell")
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.notifRequested = AppSettings.getPrefPaymentConfirmation()
        if self.fromAccount == nil {
            self.fromAccount = HGCWallet.masterWallet()?.allAccounts().first
        }
        
        if self.request != nil {
            if (self.request?.amount)! > 0 {
                self.amount = (self.request?.amount)!
            }
            if self.request?.fromAccount != nil {
                self.toAccount = self.request?.fromAccount
            }
        }
        updateFee()
        self.reloadUI()
    }
    
    func forToken() -> Bool {
        return token != nil
    }
    
    func reloadUI() {
        self.tableView.reloadData()
    }
    
    func updateFee() {
        let amnt:UInt64 = self.amount == nil ? 0 : UInt64(self.amount!)
        let txn = APIRequestBuilder.requestForTransfer(fromAccount: self.fromAccount!, toAccount: HGCAccountID.init(shardId: 0, realmId: 0, accountId: 0), amount: amnt, notes: self.notes, fee: APIRequestBuilder.placeholderFee)
        fee = APIRequestBuilder.feeForTransfer(txn)
    }
    
    @objc func onCloseButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onFromAccountChangeButtonTap() {
        let vc = AccountListViewController.getInstance()
        vc.pickeMode = true
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pickExisting() {
        if selfMode {
           
        } else {
            let vc = ContactPicker.getInstance()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onToAccountChangeButtonTap() {
        self.toAccount = nil
        self.isNewSelected = false
        self.reloadUI()
    }
    
    func onPayButtonTap() {
        self.view.endEditing(true)
        var error : String?
        
        if self.fromAccount == nil {
            error = NSLocalizedString("From account ID is mandatory", comment: "")
            
        } else if self.fromAccount?.accountID() == nil {
            error = NSLocalizedString("From account is not linked", comment: "")
            
        } else if toAccount?.accountID == nil {
            error = NSLocalizedString("Invalid to account ID", comment: "")
            
        } else if amount == nil || amount! <= 0 {
            error = NSLocalizedString("Invalid amount", comment: "")
            
        } else if (selfMode || forToken()) && gas == 0 {
            error = NSLocalizedString("Invalid gas", comment: "")
            
        } else if forToken() && toAccount?.accountID == nil {
            error = NSLocalizedString("Invalid to account ID", comment: "")
        }
        
        if error != nil {
            Globals.showGenericAlert(title: error, message: "")
            return
        }
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        let op = TransferOperation.init(fromAccount: self.fromAccount!, toAccount: self.toAccount!.accountID!, toAccountName: self.toAccount?.name, amount: UInt64(self.amount!), notes: self.notes, fee: UInt64(fee))
        op.completionBlock = {
            OperationQueue.main.addOperation({
                self.hideHud(hud)
                if let err = op.errorMessage {
                    self.onFail(err, nil)
                } else {
                    self.onTransferSuccess()
                }
            })
        }
        queue.addOperation(op)
    }
    
    
    func onTransferSuccess() {
        if let req = self.request {
            CoreDataManager.shared.mainContext.delete(req)
        }
        Globals.showGenericAlert(title: NSLocalizedString("Transaction submitted successfully", comment: ""), message: "")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
            BalanceService.defaultService.updateBalances()
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func onToAccountReceived() {
//        if let acc = self.toAccount {
//            let r = URLRequestBuilder.init(account: acc, type: .importAccount)
//            let vc = QRPreviewController.getInstance(r.requestUrl(forText: true))
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func onFail(_ title:String, _ message: String?) {
        DispatchQueue.main.async {
            Globals.showGenericErrorAlert(title: title, message: message)
        }
    }
    
    func hideHud(_ hud:MBProgressHUD) {
        DispatchQueue.main.async {
            hud.hide(animated: true)
        }
    }
}

extension PayViewController  {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == PayViewController.rowIndexOptions && (self.selfMode || self.forToken()) {
            return 0
        }
        if !self.hasNotes && indexPath.row == PayViewController.rowIndexNotes {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case PayViewController.rowIndexFrom:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAddressTableCell", for: indexPath) as! MyAddressTableCell
            cell.delegate = self
            cell.captionLabel.text = NSLocalizedString("FROM", comment: "")
            cell.setAccount(self.fromAccount!)
            return cell
            
        case PayViewController.rowIndexTo:
            if self.toAccount != nil || self.isNewSelected {
                let cell = tableView.dequeueReusableCell(withIdentifier: "accountAddressTableCell", for: indexPath) as! AddressTableViewCell
                cell.delegate = self
                cell.allowEditing = true
                cell.captionLabel.text = NSLocalizedString("TO", comment: "")
                cell.actionButton.setTitle(NSLocalizedString("CANCEL", comment: ""), for: .normal)
                cell.nameLabel.text = self.toAccount?.name
                cell.keyLabel.text = self.toAccount?.stringRepresentation()
                return cell
                
            } else {
                if self.isQROptionSelected {
                    if qrCell == nil {
                        qrCell = tableView.dequeueReusableCell(withIdentifier: "QRScanTableCell", for: indexPath) as? QRScanTableCell
                    }
                    
                    qrCell?.delegate = self
                    qrCell?.scan()
                    return qrCell!
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddressOptionsTableCell", for: indexPath) as! AddressOptionsTableCell
                    cell.delegate = self
                    cell.setTitle(NSLocalizedString("EXISTING", comment: ""), atIndex: 0)
                    cell.setTitle(NSLocalizedString("SCAN QR", comment: ""), atIndex: 2)
                    if selfMode {
                        cell.removeButtonAtIndex(index: 1)
                    } else {
                        cell.setTitle(NSLocalizedString("NEW", comment: ""), atIndex: 1)
                    }
                    return cell
                }
                
            }
            
        case PayViewController.rowIndexAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmountTableViewCell", for: indexPath) as! AmountTableViewCell
            cell.delegate = self
            cell.hgcTextField.text = self.amount == 0 ? "" : self.amount!.toCoins().description
            cell.usdTextField.text = self.amount == 0 ? "" : CurrencyConverter.shared.convertTo$value(self.amount!).description
            return cell
            
        case PayViewController.rowIndexOptions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TXNOptionsTableCell", for: indexPath) as! TXNOptionsTableCell
            cell.delegate = self
            cell.notesSwitch.setOn(self.hasNotes, animated: false)
            cell.notificationSwitch.setOn(self.notifRequested, animated: false)
            return cell
            
        case PayViewController.rowIndexFee:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeeTableCell", for: indexPath) as! FeeTableCell
            cell.feeLabel.setAmount(Int64(fee))
            if selfMode || forToken() {
                cell.gasCaptionLabel.isHidden = false
                cell.gasTextField.isHidden = false
                cell.gasTextField.text = gas.description
            }
            
            return cell
        case PayViewController.rowIndexNotes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
            cell.delegate = self
            cell.textView.text = self.notes
            return cell
            
        case PayViewController.rowIndexPay:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionButtonTableCell", for: indexPath) as! ActionButtonTableCell
            cell.delegate = self
            cell.setTitle(NSLocalizedString("PAY", comment: ""))
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountAddressTableCell", for: indexPath) as! AddressTableViewCell
            
            return cell
        }
    }
}

extension PayViewController : AccountPickerDelegate {
    func accountPickerDidPickAccount(_ picker: AccountListViewController, accont: HGCAccount) {
        self.navigationController?.popToViewController(self, animated: true)
        self.fromAccount = accont
        self.reloadUI()
    }
}

extension PayViewController : AmountTableViewCellDelegate {
    func amountTableViewCellDidChange(_ cell: AmountTableViewCell, nanaoCoins: Int64) {
        self.amount = nanaoCoins
    }
    
    func amountTableViewCellDidEndEditing(_ cell: AmountTableViewCell) {
        updateFee()
        self.reloadUI()
    }
}

extension PayViewController : AddressTableViewCellDelegate {
    func addressTableViewCellDidTapCopyButton(_ cell: AddressTableViewCell) {
    }
    
    func addressTableViewCellDidChange(_ cell: AddressTableViewCell, name: String, address: String) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row == PayViewController.rowIndexFrom {
                
                
            } else if indexPath.row == PayViewController.rowIndexTo {
                if let account = AccountVO.init(from: address, name: name) {
                    self.toAccount = account
                } else {
                    self.toAccount = nil
                }
            }
        }
    }
    
    func addressTableViewCellDidTapActionButton(_ cell: AddressTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            if indexPath.row == PayViewController.rowIndexFrom {
                self.onFromAccountChangeButtonTap()
                
            } else if indexPath.row == PayViewController.rowIndexTo {
                self.onToAccountChangeButtonTap()
            }
        }
    }
}

extension PayViewController : AddressOptionsTableCellDelegate {
    func optionsTableViewCellDidTapatIndex(_ cell: AddressOptionsTableCell, index: Int) {
        switch index {
        case 0:
            self.pickExisting()
            
        case 1:
            self.isNewSelected = true
            self.reloadUI()
            
        case 2:
            self.isQROptionSelected = true
            self.reloadUI();
        default:
            break
        }
    }
}

extension PayViewController : ActionButtonTableCellDelegate {
    func actionButtonCellDidTapActionButton(_ cell: ActionButtonTableCell) {
        self.onPayButtonTap()
        
    }
}

extension PayViewController : TXNOptionsTableCellDelegate {
    func optionsTableCellDidChangeForNotification(_ cell: TXNOptionsTableCell, value: Bool) {
       
    }
    
    func optionsTableCellDidChangeForNotes(_ cell: TXNOptionsTableCell, value: Bool) {
        self.hasNotes = value
        self.reloadUI()
    }
}

extension PayViewController : QRScanTableCellDelegate {
    func scanTableCellDidCancel(_ cell: QRScanTableCell) {
        self.isQROptionSelected = false
        self.reloadUI()
    }
    
    func scanTableCellDidScan(_ cell: QRScanTableCell, results: [String]) {
        var requestParser : TransferRequestParams? = nil
        for code in results {
            if let parser = TransferRequestParams.init(qrCode: code) {
                requestParser = parser
                break;
            }
        }
        
        if let parser = requestParser {
            self.toAccount = AccountVO.init(accountID: parser.account)
            self.toAccount?.name = parser.name
            if (parser.amount != nil) {
                self.amount = parser.amount
            }
        } else {
            Globals.showGenericAlert(title: NSLocalizedString("Invalid QR Code", comment: ""), message: nil)
        }
        
        cell.stopScan()
        self.isQROptionSelected = false
        self.reloadUI()
    }
}

extension PayViewController : NotesTableViewCellDelegate {
    func notesTableViewCellShouldUpdateNewText(_ cell: NotesTableViewCell, text: String) -> Bool {
        return text.utf8.count <= 100
    }
    
    func notesTableViewCellDidChange(_ cell: NotesTableViewCell, text: String) {
        self.notes = text
    }
}

extension PayViewController : ContactPickerDelegate {
    func contactPickerDidPickAccount(_ picker: ContactPicker, account: HGCAccount) {
        if let accID = account.accountID() {
            self.toAccount = AccountVO.init(accountID: accID, address: nil, name: account.name)
            self.reloadUI()
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
    
    func contactPickerDidPickContact(_ picker: ContactPicker, contact: HGCContact) {
        self.toAccount = AccountVO.init(from: contact.publicKeyID!, name: contact.name)
        self.reloadUI()
        self.navigationController?.popToViewController(self, animated: true)
    }
}

extension PayViewController : MyAddressTableCellDelegate {
    func myAddressTableCellDidTapOnActionButton(_ cell: MyAddressTableCell) {
        self.onFromAccountChangeButtonTap()
    }
}
