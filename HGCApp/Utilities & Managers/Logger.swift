//
//  Logger.swift
//  HGCApp
//
//  Created by Surendra  on 03/05/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import Foundation

// Enum for showing the type of Log Types
enum LogEvent: String {
    case e = "[‼️]" // error
    case i = "[ℹ️]" // info
    case d = "[💬]" // debug
    case v = "[🔬]" // verbose
    case w = "[⚠️]" // warning
    case s = "[🔥]" // severe
}

class Logger {
    static let instance = Logger()
    let queue : OperationQueue = {
        let q = OperationQueue.init()
            q.maxConcurrentOperationCount = 1
            return q
        }()
    
    var logs : [String] = []
    var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    func log(message: String,
                   event: LogEvent,
                   fileName: String = #file,
                   line: Int = #line,
                   column: Int = #column,
                   funcName: String = #function) {
        
        if loggingEnabled {
            queue.addOperation {
                let log = "\n\(Date().toLogString()) \(event.rawValue)[\(self.sourceFileName(filePath: fileName))]:\(line) \(column) \(funcName) -> \(message)"
                self.logs.append(log)
                print(log)
            }
        }
    }
    
    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toLogString() -> String {
        return Logger.instance.dateFormatter.string(from: self as Date)
    }
}
