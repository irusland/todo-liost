//
//  LogFormetter.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 11.12.2021.
//

import Foundation
import CocoaLumberjack

class LogFormatter: DDDispatchQueueLogFormatter {
    let dateFormatter: DateFormatter
    
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "HH:mm"
        
        
        super.init()
    }
    
    override func format(message logMessage: DDLogMessage) -> String {
        let dateAndTime = dateFormatter.string(from: logMessage.timestamp)
        return "\(dateAndTime) [\(logMessage.fileName):\(logMessage.line)]: \(logMessage.message)"
    }
}
