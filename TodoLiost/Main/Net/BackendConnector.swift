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

    func getList(handler: @escaping (Result<ListModel, BackendErrors>) -> Void, using session: URLSession = .shared) {
        guard let token = authViewController.authCredentials?.accessToken else {
            handler(Result.failure(BackendErrors.tokenIsNone("Token is none")))
            return
        }

        _ = session.request(.list(token: token)) { data, response, error in
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
                let listResponse = try decoder.decode(ListModel.self, from: body)
                DDLogInfo("Got list \(String(describing: listResponse))")
                handler(Result.success(listResponse))
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
                handler(Result.failure(BackendErrors.parseError(body, error)))
            }
        }
    }

    func merge(with model: MergeModel, handler: @escaping (Result<ListModel, BackendErrors>) -> Void, using session: URLSession = .shared) {
        guard let token = authViewController.authCredentials?.accessToken else {
            handler(Result.failure(BackendErrors.tokenIsNone("Token is none")))
            return
        }

        var endpoint: Endpoint?
        do {
            endpoint = try Endpoint.merge(with: model, token: token)
        } catch {
            handler(Result.failure(BackendErrors.cannotPrepareEndpoint))
        }
        guard let endpoint = endpoint else {
            handler(Result.failure(BackendErrors.cannotPrepareEndpoint))
            return
        }

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
                let listResponse = try decoder.decode(ListModel.self, from: body)
                DDLogInfo("Got list \(String(describing: listResponse))")
                handler(Result.success(listResponse))
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
                handler(Result.failure(BackendErrors.parseError(body, error)))
            }
        }
    }

    func add(todoItem: NewItemModel, lastKnownRevision: Int32, handler: @escaping (Result<NewItemResponse, BackendErrors>) -> Void, using session: URLSession = .shared) {
        guard let token = authViewController.authCredentials?.accessToken else {
            handler(Result.failure(BackendErrors.tokenIsNone("Token is none")))
            return
        }
        var endpoint: Endpoint?
        do {
            endpoint = try Endpoint.newItem(with: todoItem, last: lastKnownRevision, token: token)
        } catch {
            handler(Result.failure(BackendErrors.cannotPrepareEndpoint))
        }
        guard let endpoint = endpoint else {
            handler(Result.failure(BackendErrors.cannotPrepareEndpoint))
            return
        }
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
                let listResponse = try decoder.decode(NewItemResponse.self, from: body)
                DDLogInfo("Got list \(String(describing: listResponse))")
                handler(Result.success(listResponse))
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
                handler(Result.failure(BackendErrors.parseError(body, error)))
            }
        }

    }

    func update(at id: UUID, todoItem: NewItemModel, lastKnownRevision: Int32, handler: @escaping (NewItemResponse?, BackendErrors?) -> Void, using session: URLSession = .shared) {
        guard let token = authViewController.authCredentials?.accessToken else {
            handler(nil, BackendErrors.tokenIsNone("Token is none"))
            return
        }

        var endpoint: Endpoint?
        do {
            endpoint = try Endpoint.updateItem(with: id, newItemModel: todoItem, last: lastKnownRevision, token: token)
        } catch {
            handler(nil, BackendErrors.cannotPrepareEndpoint)
        }
        guard let endpoint = endpoint else {
            handler(nil, BackendErrors.cannotPrepareEndpoint)
            return
        }

        _ = session.request(endpoint) { data, response, error in
            if let backendError = self.checkStatus(response: response) {
                handler(nil, backendError)
            }
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                let listResponse = try decoder.decode(NewItemResponse.self, from: body)
                DDLogInfo("Got list \(String(describing: listResponse))")
                handler(listResponse, nil)
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
                handler(nil, BackendErrors.parseError(body, error))
            }
        }

    }

    func remove(by id: UUID, lastKnownRevision: Int32, handler: @escaping (NewItemResponse?, BackendErrors?) -> Void, using session: URLSession = .shared) {
        guard let token = authViewController.authCredentials?.accessToken else {
            handler(nil, BackendErrors.tokenIsNone("Token is none"))
            return
        }

        var endpoint: Endpoint?
        do {
            endpoint = try Endpoint.deleteItem(with: id, last: lastKnownRevision, token: token)
        } catch {
            handler(nil, BackendErrors.cannotPrepareEndpoint)
        }
        guard let endpoint = endpoint else {
            handler(nil, BackendErrors.cannotPrepareEndpoint)
            return
        }

        _ = session.request(endpoint) { data, response, error in
            if let backendError = self.checkStatus(response: response) {
                handler(nil, backendError)
            }
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                let listResponse = try decoder.decode(NewItemResponse.self, from: body)
                DDLogInfo("Got list \(String(describing: listResponse))")
                handler(listResponse, nil)
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
                handler(nil, BackendErrors.parseError(body, error))
            }
        }
    }

    func get(by id: UUID, lastKnownRevision: Int32, handler: @escaping (NewItemResponse?, BackendErrors?) -> Void, using session: URLSession = .shared) {

        guard let token = authViewController.authCredentials?.accessToken else {
            handler(nil, BackendErrors.tokenIsNone("Token is none"))
            return
        }

        _ = session.request(.item(with: id, last: lastKnownRevision, token: token)) { data, response, error in
            if let backendError = self.checkStatus(response: response) {
                handler(nil, backendError)
            }
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                let listResponse = try decoder.decode(NewItemResponse.self, from: body)
                DDLogInfo("Got list \(String(describing: listResponse))")
                handler(listResponse, nil)
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
                handler(nil, BackendErrors.parseError(body, error))
            }
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
