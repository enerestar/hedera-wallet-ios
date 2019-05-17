//
//  HAPI+TimeInterval.swift
//  HGCApp
//
//  Created by Surendra on 15/04/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import Foundation

extension TimeInterval {
    func protoDuration() -> Proto_Duration {
        var d = Proto_Duration.init()
        let o = self.extractSecondsAndNanos()
        d.seconds = o.seconds
        return d
    }
    
    func protoTimestamp() -> Proto_Timestamp {
        var d = Proto_Timestamp.init()
        let o = self.extractSecondsAndNanos()
        d.seconds = o.seconds
        d.nanos = o.nanos
        return d
    }
    
    func extractSecondsAndNanos() -> (seconds:Int64, nanos:Int32) {
        let seconds = Int64(floor(self))
        let nanos = Int32((self - TimeInterval(seconds)) * 1000000000)
        return (seconds, nanos)
    }
}
