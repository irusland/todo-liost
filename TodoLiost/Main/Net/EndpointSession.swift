//
//  EndpointSession.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation
import CocoaLumberjack

extension URLSession {
    typealias Handler = (Data?, URLResponse?, Error?) -> Void
    

    @discardableResult
    func request(_ endpoint: Endpoint, with headers: Headers = [:], then handler: @escaping Handler) -> URLSessionDataTask {
        var request = endpoint.request
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        DDLogInfo("Starting request \(endpoint.url), \(endpoint.queryItems)")
        
        func notify(data: Data?, response: URLResponse?, error: Error?) {
            DDLogInfo("Finished request \(endpoint.url), \(endpoint.queryItems)")
            return handler(data, response, error)
        }
        
        
        let task = dataTask(
            with: request,
            completionHandler: notify
        )
        
        task.resume()
        return task
    }
}
