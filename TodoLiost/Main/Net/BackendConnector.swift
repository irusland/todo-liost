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
        with handler: @escaping (Result<T, BackendErrors>) -> Void,
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
                handler(Result.failure(BackendErrors.parseError(body, error)))
            }
        }
    }
    
    private func prepareEndpoint(endpointInitialiser: (String) throws -> Endpoint?) -> Result<Endpoint, BackendErrors> {
        guard let token = authViewController.authCredentials?.accessToken else {
            return Result.failure(BackendErrors.tokenIsNone("Token is none"))
        }
        var endpoint: Endpoint?
        do {
            endpoint = try endpointInitialiser(token)
        } catch {
            return Result.failure(BackendErrors.cannotPrepareEndpoint)
        }
        guard let endpoint = endpoint else {
            return Result.failure(BackendErrors.cannotPrepareEndpoint)
        }
        return Result.success(endpoint)
    }

    func getList(handler: @escaping (Result<ListModel, BackendErrors>) -> Void, using session: URLSession = .shared) {
        let preparation = prepareEndpoint(endpointInitialiser: { token in .list(token: token) })
        switch preparation {
        case .success(let endpoint):
            self.request(endpoint: endpoint, with: handler)
            return
        case .failure(let error):
            handler(Result.failure(error))
        }
        
    }

    func merge(with model: MergeModel, handler: @escaping (Result<ListModel, BackendErrors>) -> Void, using session: URLSession = .shared) {
        let preparation = prepareEndpoint(endpointInitialiser: { token in try .merge(with: model, token: token) })
        switch preparation {
        case .success(let endpoint):
            self.request(endpoint: endpoint, with: handler)
            return
        case .failure(let error):
            handler(Result.failure(error))
        }
    }

    func add(todoItem: NewItemModel, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendErrors>) -> Void, using session: URLSession = .shared) {
        let preparation = prepareEndpoint(endpointInitialiser: { token in try .newItem(with: todoItem, last: lastKnownRevision, token: token) })
        switch preparation {
        case .success(let endpoint):
            self.request(endpoint: endpoint, with: handler)
            return
        case .failure(let error):
            handler(Result.failure(error))
        }
    }

    func update(at id: UUID, todoItem: NewItemModel, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendErrors>) -> Void, using session: URLSession = .shared) {
        let preparation = prepareEndpoint(endpointInitialiser: { token in try .updateItem(with: id, newItemModel: todoItem, last: lastKnownRevision, token: token) })
        switch preparation {
        case .success(let endpoint):
            self.request(endpoint: endpoint, with: handler)
            return
        case .failure(let error):
            handler(Result.failure(error))
        }
    }

    func remove(by id: UUID, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendErrors>) -> Void, using session: URLSession = .shared) {
        let preparation = prepareEndpoint(endpointInitialiser: { token in try .deleteItem(with: id, last: lastKnownRevision, token: token) })
        switch preparation {
        case .success(let endpoint):
            self.request(endpoint: endpoint, with: handler)
            return
        case .failure(let error):
            handler(Result.failure(error))
        }
    }

    func get(by id: UUID, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendErrors>) -> Void, using session: URLSession = .shared) {
        let preparation = prepareEndpoint(endpointInitialiser: { token in try .item(with: id, last: lastKnownRevision, token: token) })
        switch preparation {
        case .success(let endpoint):
            self.request(endpoint: endpoint, with: handler)
            return
        case .failure(let error):
            handler(Result.failure(error))
        }
    }

    private func checkStatus(response: URLResponse?) -> BackendErrors? {
        guard let response = response as? HTTPURLResponse else {
            DDLogError("Response is nil")
            return nil
        }
        switch response.statusCode {
        case 200:
            return nil
        case 400:
            return BackendErrors.unsynchronizedRevision
        case 404:
            return BackendErrors.notFound
        case 401:
            return BackendErrors.unauthorized
        default:
            return nil
        }
    }
}
