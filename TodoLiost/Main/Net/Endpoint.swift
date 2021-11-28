//
//  Endpoint.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation


typealias Headers = [String: String]

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "beta.mrdekk.ru"
        components.path = "/todobackend/" + path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        
        return url
    }
    
    var request: URLRequest {
        var request = URLRequest(url: self.url)
        return request
    }
}

extension Endpoint {
    static var list: Self {
        Endpoint(path: "list")
    }
    static func search(for query: String,
                       maxResultCount: Int = 100) -> Self {
        Endpoint(
            path: "search/\(query)",
            queryItems: [URLQueryItem(
                name: "count",
                value: String(maxResultCount)
            )]
        )
    }
}
