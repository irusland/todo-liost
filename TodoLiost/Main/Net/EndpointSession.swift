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

        DDLogInfo("Starting request \(endpoint.method) \(endpoint.url) \nbody: \(String(decoding: endpoint.body ?? Data(), as: UTF8.self))  \nheaders: \(String(describing: endpoint.request.allHTTPHeaderFields))")

        func notify(data: Data?, response: URLResponse?, error: Error?) {
            var decodedBody = ""
            if let body = data {
                decodedBody = String(decoding: body, as: UTF8.self)
            }
            DDLogInfo("Finished request \(endpoint.method) \(endpoint.url) -> \ndata: \(decodedBody); \nresponse: \(String(describing: response)); \nerror: \(String(describing: error))")
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
