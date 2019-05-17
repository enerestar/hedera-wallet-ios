//
//  TransactionService.swift
//  HGCApp
//
//  Created by Surendra  on 09/12/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let onTransactionsUpdate = Notification.Name("onTransactionsUpdate")
    static let onTransactionsServiceStateChanged = Notification.Name("onTransactionsServiceStateChanged")
}

class TransactionService {
    
    static let defaultService : TransactionService = TransactionService();
    private var coreDataManager : CoreDataManagerProtocol
    private var operation : UpdateTransactionsOperation?

    init( coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    public func isRunning() -> Bool {
        return operation?.isExecuting ?? false
    }
    
    func updateTransactions() {
        if hasOperation() {
            return
        }
        
        let op = UpdateTransactionsOperation()
        op.completionBlock = {
            OperationQueue.main.addOperation {
                if let errorMsg = op.errorMessage {
                    Globals.showGenericErrorAlert(title: "Failed to update transaction records", message: errorMsg)
                }
            }
        }
        BaseOperation.operationQueue.addOperation(op)
        operation = op
    }
    
    func hasOperation() -> Bool {
        for operation in BaseOperation.operationQueue.operations {
            if operation is UpdateTransactionsOperation {
                return true
            }
        }
        return false
    }
}
