//
//  SCToken.swift
//  HGCApp
//
//  Created by Surendra  on 22/06/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit

extension SCToken {
    static let entityName = "SCToken"
    
    func token() -> TokenVO {
        return TokenVO.init(contractID: HGCAccountID.init(from: contractID)!, name: name!, symbol: symbol!, decimals: decimals)
    }
    
}
