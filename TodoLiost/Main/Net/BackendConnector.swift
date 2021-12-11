//
//  BackendConnector.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 28.11.2021.
//

import Foundation
import CocoaLumberjack

class BackendConnector {
    private var auth: Auth
    
    init(auth: Auth) {
        self.auth = auth
    }
    
    func getList(using session: URLSession = .shared) throws -> ListModel? {
        let sem = DispatchSemaphore(value: 0)
        guard let token = auth.authCredentials?.accessToken else {
            throw BackendErrors.tokenIsNone("Token is none")
        }
        var listResponse: ListModel?
        var backendError: BackendErrors?
        
        _ = session.request(.list(token: token)) { data, response, error in
            defer { sem.signal() }
            backendError = self.checkStatus(response: response)
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                listResponse = try decoder.decode(ListModel.self, from: body)
                DDLogInfo("Got list \(String(describing: listResponse))")
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
            }
        }
        sem.wait()
        if let error = backendError {
            throw error
        }
        return listResponse
    }

    func merge(with model: MergeModel, using session: URLSession = .shared) throws -> ListModel? {
        let sem = DispatchSemaphore(value: 0)
        guard let token = auth.authCredentials?.accessToken else {
            throw BackendErrors.tokenIsNone("Token is none")
        }
        var listResponse: ListModel?
        var backendError: BackendErrors?
        var endpoint: Endpoint?
        do {
            endpoint = try Endpoint.merge(with: model, token: token)
        } catch {
            throw BackendErrors.cannotPrepareEndpoint
        }
        guard let endpoint = endpoint else {
            throw BackendErrors.cannotPrepareEndpoint
        }
        
        _ = session.request(endpoint) { data, response, error in
            defer { sem.signal() }
            backendError = self.checkStatus(response: response)
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                listResponse = try decoder.decode(ListModel.self, from: body)
                DDLogInfo("Got list \(String(describing: listResponse))")
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
            }
        }
        sem.wait()
        if let error = backendError {
            throw error
        }
        return listResponse
    }
    
    func add(todoItem: NewItemModel, lastKnownRevision: Int32, using session: URLSession = .shared) throws -> NewItemResponse? {
        let sem = DispatchSemaphore(value: 0)
        guard let token = auth.authCredentials?.accessToken else {
            throw BackendErrors.tokenIsNone("Token is none")
        }
        var result: NewItemResponse?
        var endpoint: Endpoint?
        do {
            endpoint = try Endpoint.newItem(with: todoItem, last: lastKnownRevision, token: token)
        } catch {
            throw BackendErrors.cannotPrepareEndpoint
        }
        guard let endpoint = endpoint else {
            throw BackendErrors.cannotPrepareEndpoint
        }
        
        var backendError: BackendErrors?
        _ = session.request(endpoint) { data, response, error in
            defer { sem.signal() }
            backendError = self.checkStatus(response: response)
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                result = try decoder.decode(NewItemResponse.self, from: body)
                DDLogInfo("Got \(String(describing: result))")
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
            }
        }
        sem.wait()
        if let error = backendError {
            throw error
        }
        return result
    }
    
    func update(at id: UUID, todoItem: NewItemModel, lastKnownRevision: Int32, using session: URLSession = .shared) throws -> NewItemResponse?  {
        let sem = DispatchSemaphore(value: 0)
        guard let token = auth.authCredentials?.accessToken else {
            throw BackendErrors.tokenIsNone("Token is none")
        }
        var result: NewItemResponse?
        var endpoint: Endpoint?
        do {
            endpoint = try Endpoint.updateItem(with: id, newItemModel: todoItem, last: lastKnownRevision, token: token)
        } catch {
            throw BackendErrors.cannotPrepareEndpoint
        }
        guard let endpoint = endpoint else {
            throw BackendErrors.cannotPrepareEndpoint
        }
        
        var backendError: BackendErrors?
        _ = session.request(endpoint) { data, response, error in
            defer { sem.signal() }
            backendError = self.checkStatus(response: response)
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                result = try decoder.decode(NewItemResponse.self, from: body)
                DDLogInfo("Got \(String(describing: result))")
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
            }
        }
        sem.wait()
        if let error = backendError {
            throw error
        }
        return result
    }
    
    func remove(by id: UUID, lastKnownRevision: Int32, using session: URLSession = .shared) throws -> NewItemResponse?  {
        let sem = DispatchSemaphore(value: 0)
        guard let token = auth.authCredentials?.accessToken else {
            throw BackendErrors.tokenIsNone("Token is none")
        }
        var result: NewItemResponse?
        var endpoint: Endpoint?
        do {
            endpoint = try Endpoint.deleteItem(with: id, last: lastKnownRevision, token: token)
        } catch {
            throw BackendErrors.cannotPrepareEndpoint
        }
        guard let endpoint = endpoint else {
            throw BackendErrors.cannotPrepareEndpoint
        }
        
        var backendError: BackendErrors?
        _ = session.request(endpoint) { data, response, error in
            defer { sem.signal() }
            backendError = self.checkStatus(response: response)
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                result = try decoder.decode(NewItemResponse.self, from: body)
                DDLogInfo("Got \(String(describing: result))")
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
            }
        }
        sem.wait()
        if let error = backendError {
            throw error
        }
        return result
    }
    
    func get(by id: UUID, lastKnownRevision: Int32, using session: URLSession = .shared) throws -> NewItemResponse?  {
        let sem = DispatchSemaphore(value: 0)
        guard let token = auth.authCredentials?.accessToken else {
            throw BackendErrors.tokenIsNone("Token is none")
        }
        var result: NewItemResponse?
        var backendError: BackendErrors?
        _ = session.request(.item(with: id, last: lastKnownRevision, token: token)) { data, response, error in
            defer { sem.signal() }
            backendError = self.checkStatus(response: response)
            guard let body = data else {
                DDLogError("Data is empty")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                result = try decoder.decode(NewItemResponse.self, from: body)
                DDLogInfo("Got \(String(describing: result))")
            } catch {
                DDLogInfo("Cannot parse \(body) \(error)")
            }
        }
        sem.wait()
        if let error = backendError {
            throw error
        }
        return result
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
