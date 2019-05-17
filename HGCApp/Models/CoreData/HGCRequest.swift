//
//  HGCRequest+CoreDataClass.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//
//

import Foundation
import CoreData

extension HGCRequest {
    public static let entityName = "Request"

    static func createRequest(fromAddress:String, _ context: NSManagedObjectContext ) -> HGCRequest {
        let request = NSEntityDescription.insertNewObject(forEntityName: HGCRequest.entityName, into: context) as! HGCRequest
        request.importTime = Date()
        request.fromAddress = fromAddress
        return request
    }
    
    static func allRequests(_ context: NSManagedObjectContext) -> [HGCRequest] {
        let fetchRequest = HGCRequest.fetchRequest() as NSFetchRequest<HGCRequest>
        let sortDesc = NSSortDescriptor.init(key: "importTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc]
        let result = try? context.fetch(fetchRequest)
        if result != nil {
            return result!
        }
        
        return [HGCRequest]()
    }
    
    static func requestFor(_ params:TransferRequestParams, _ context:NSManagedObjectContext ) -> HGCRequest? {
        let amount = params.amount ?? -1
        for request in self.allRequests(context) {
            if request.fromName == params.name && request.fromAddress == params.account.stringRepresentation() && request.amount == amount && request.note == params.note && request.notificationRequested == params.notify {
                return request
            }
        }
        return nil
    }
    
    var fromAccount :  AccountVO? {
        return AccountVO.init(from: self.fromAddress, name: self.fromName)
    }
}
