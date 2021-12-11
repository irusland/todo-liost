//
//  DateExtension.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 12.11.2021.
//

import UIKit

extension Date {
    var string: String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short

        return dateFormatter.string(from: self)
    }

    var unixTimestamp: Int64 {
        return Int64(self.timeIntervalSince1970)
    }
}
