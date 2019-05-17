//
//  UIAlertController+Add.swift
//  HGCApp
//
//  Created by Surendra  on 23/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

var alertKey : String = "alertKey";

extension UIAlertController {
    
    var alertWindow : UIWindow? {
        set {
            objc_setAssociatedObject(self, &alertKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
        get {
            return objc_getAssociatedObject(self, &alertKey) as! UIWindow?;
        }
    }
}

extension UIAlertController {

    func showAlert() {
        self.alertWindow = UIWindow.init(frame: UIScreen.main.bounds);
        self.alertWindow?.rootViewController = UIViewController.init();
        
        self.alertWindow?.tintColor = UIApplication.shared.delegate?.window??.tintColor;
        let topWindow = UIApplication.shared.windows.last;
        self.alertWindow?.windowLevel = (topWindow?.windowLevel)! + 1;
        
        self.alertWindow?.makeKeyAndVisible();
        self.alertWindow?.rootViewController?.present(self, animated: true, completion: nil);
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        self.alertWindow?.isHidden = true;
        self.alertWindow = nil;
    }
    
    func dismissAlert() {
        weak var weakSelf = self;
        self.alertWindow?.rootViewController?.dismiss(animated: true, completion: { 
            weakSelf?.alertWindow?.isHidden = true;
            weakSelf?.alertWindow = nil;
        })
    }
    
    func isVisibleAlert() -> Bool {
        return self.alertWindow != nil;
    }
    
}


extension UIAlertController {
    class func alert(title:String? = nil, message:String? = nil) -> UIAlertController {
        return UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    }
    
    @discardableResult
    func addDismissButton(title:String? = NSLocalizedString("Dismiss", comment: ""), _ onDismiss:((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        self.addAction(UIAlertAction.init(title: title, style: .cancel, handler: onDismiss))
        return self
    }
    
    @discardableResult
    func addConfirmButton(title:String, _ onConfirm:((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        self.addAction(UIAlertAction.init(title: title, style: .default, handler: onConfirm))
        return self
    }
    
    @discardableResult
    func show(from:UIViewController?) -> UIAlertController {
        from?.present(self, animated: true, completion: nil)
        return self
    }
}
