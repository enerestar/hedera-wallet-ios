//
//  QRScanTableTableCell.swift
//  HGCApp
//
//  Created by Surendra  on 11/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import MTBBarcodeScanner

protocol QRScanTableCellDelegate : class {
    func scanTableCellDidCancel(_ cell:QRScanTableCell)
    func scanTableCellDidScan(_ cell:QRScanTableCell, results: [String])
    
}

class QRScanTableCell: UITableViewCell {

    @IBOutlet weak var scanView : UIView!
    @IBOutlet weak var button : UIButton!
    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var errorLabel : UILabel!
    
    var scanner: MTBBarcodeScanner?
    var hasMovedToWindow = false
    var isScanning = false
    weak var delegate : QRScanTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scanner = MTBBarcodeScanner(previewView: self.scanView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
        HGCStyle.regularCaptionLabel(self.captionLabel)
        self.errorLabel.font = Font.regularFont(12.0)
        self.errorLabel.textColor = UIColor.red
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        hasMovedToWindow = true
        self.scan()
    }
    
    func stopScan() {
        self.scanner?.stopScanning()
        isScanning = false
    }
    
    func scan() {
        if isScanning || !hasMovedToWindow { return }
        
        isScanning = true
        self.errorLabel.isHidden = true
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            var results = [String]()
                            for code in codes {
                                let stringValue = code.stringValue!
                                Logger.instance.log(message: stringValue, event: .d)
                                results.append(stringValue)
                            }
                            self.delegate?.scanTableCellDidScan(self, results: results)
                        }
                    })
                } catch {
                    self.stopWithMessage(NSLocalizedString("Unable to start scanning", comment: ""))
                }
            } else {
                if self.isScanning {
                    self.stopWithMessage(NSLocalizedString("Don't have camera permissions", comment: ""))
                }
            }
        })
    }
    
    @IBAction func handleTapOnCancel() {
        self.stopScan()
        self.delegate?.scanTableCellDidCancel(self)
    }
    
    func stopWithMessage(_ message:String?) {
        self.errorLabel.isHidden = false
        self.errorLabel.text = message
        self.stopScan()
    }
}
