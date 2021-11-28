//
//  Request.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation

extension URLRequest {
    mutating func with(headers: Headers) {
        for (header, value) in headers {
            self.setValue(value, forHTTPHeaderField: header)
        }
    }
}
