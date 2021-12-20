//
//  BackendConnector.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation
import CocoaLumberjack

class BackendConnector {
    private var authViewController: AuthViewController

    init(authViewController: AuthViewController) {
        self.authViewController = authViewController
    }

    private func request<T: Decodable>(
        endpoint: Endpoint,
        with handler: @escaping (Result<T, BackendError>) -> Void,
        using session: URLSession = .shared
    ) {
        _ = session.request(endpoint) { data, response, error in
            if let backendError = self.checkStatus(response: response) {
                handler(Result.failure(backendError))
            }
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                let response = try decoder.decode(T.self, from: body)
                DDLogInfo("Got \(String(describing: response))")
                handler(Result.success(response))
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
                handler(Result.failure(BackendError.parseError(body, error)))
            }
        }
    }

    private func prepareEndpoint(endpointInitialiser: (String) throws -> Endpoint?) -> Result<Endpoint, BackendError> {
        guard let token = authViewController.authCredentials?.accessToken else {
            return Result.failure(BackendError.tokenIsNone("Token is none"))
        }
        var endpoint: Endpoint?
        do {
            endpoint = try endpointInitialiser(token)
        } catch {
            return Result.failure(BackendError.cannotPrepareEndpoint)
        }
        guard let endpoint = endpoint else {
            return Result.failure(BackendError.cannotPrepareEndpoint)
        }
        return Result.success(endpoint)
    }

    private func tryRequest<T: Decodable>(
        handler: @escaping (Result<T, BackendError>) -> Void,
        endpoint endpointInitialiser: (String) throws -> Endpoint?,
        using session: URLSession = .shared
    ) {
        let preparation = prepareEndpoint(endpointInitialiser: endpointInitialiser)
        switch preparation {
        case .success(let endpoint):
            self.request(endpoint: endpoint, with: handler)
            return
        case .failure(let error):
            handler(Result.failure(error))
        }
    }

    func getList(handler: @escaping (Result<ListModel, BackendError>) -> Void, using session: URLSession = .shared) {
        tryRequest(handler: handler) { token in
            .list(token: token)
        }
    }

    func merge(with model: MergeModel, handler: @escaping (Result<ListModel, BackendError>) -> Void, using session: URLSession = .shared) {
        tryRequest(handler: handler) { token in
            try .merge(with: model, token: token)
        }
    }

    func add(todoItem: NewItemModel, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendError>) -> Void, using session: URLSession = .shared) {
        tryRequest(handler: handler) { token in
            try .newItem(with: todoItem, last: lastKnownRevision, token: token)
        }
    }

    func update(at id: UUID, todoItem: NewItemModel, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendError>) -> Void, using session: URLSession = .shared) {
        tryRequest(handler: handler) { token in
            try .updateItem(with: id, newItemModel: todoItem, last: lastKnownRevision, token: token)
        }
    }

    func remove(by id: UUID, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendError>) -> Void, using session: URLSession = .shared) {
        tryRequest(handler: handler) { token in
            try .deleteItem(with: id, last: lastKnownRevision, token: token)
        }
    }

    func get(by id: UUID, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendError>) -> Void, using session: URLSession = .shared) {
        tryRequest(handler: handler) { token in
            .item(with: id, last: lastKnownRevision, token: token)
        }
    }

    private func checkStatus(response: URLResponse?) -> BackendError? {
        guard let response = response as? HTTPURLResponse else {
            DDLogError("Response is nil")
            return nil
        }
        switch response.statusCode {
        case 200:
            return nil
        case 400:
            return BackendError.unsynchronizedRevision
        case 404:
            return BackendError.notFound
        case 401:
            return BackendError.unauthorized
        default:
            return nil
        }
    }
}
