//
//  Endpoint.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation

typealias Headers = [String: String]
typealias OAuth = String

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
    var body: Data?
    var token: OAuth?
    var lastRevision: Int32?
    var method: String = "GET"
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
        request.httpMethod = self.method
        request.httpBody = self.body

        if let oauth = self.token {
            request.setValue("OAuth \(oauth)", forHTTPHeaderField: "Authorization")
        }
        if let revision = self.lastRevision {
            request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        }
        return request
    }
}

extension Endpoint {
    static func list(token: OAuth) -> Self {
        Endpoint(path: "list", token: token)
    }
    static func merge(with mergeModel: MergeModel, token: OAuth) throws -> Self {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let body = try encoder.encode(mergeModel)
            return Endpoint(path: "list", body: body, token: token, method: "PATCH")
        } catch {
            throw BackendErrors.encodingError("Cannot encode data: \(mergeModel)")
        }
    }
    static func item(with id: UUID, last revision: Int32, token: OAuth) -> Self {
        return Endpoint(path: "list/\(id)", token: token, lastRevision: revision)
    }
    static func newItem(with newItemModel: NewItemModel, last revision: Int32, token: OAuth) throws -> Self {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let body = try encoder.encode(newItemModel)
            return Endpoint(path: "list", body: body, token: token, lastRevision: revision, method: "POST")
        } catch {
            throw BackendErrors.encodingError("Cannot encode data: \(newItemModel)")
        }
    }
    static func updateItem(with id: UUID, newItemModel: NewItemModel, last revision: Int32, token: OAuth) throws -> Self {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let body = try encoder.encode(newItemModel)
            return Endpoint(path: "list/\(id)", body: body, token: token, lastRevision: revision, method: "PUT")
        } catch {
            throw BackendErrors.encodingError("Cannot encode data: \(newItemModel)")
        }
    }
    static func deleteItem(with id: UUID, last revision: Int32, token: OAuth) throws -> Self {
        return Endpoint(path: "list/\(id)", token: token, lastRevision: revision, method: "DELETE")
    }
}
