//
//  BackendErrors.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 04.12.2021.
//

import Foundation

public enum BackendErrors: Error {
    case dataIsEmpty(String)
    case tokenIsNone(String)
    case encodingError(String)
    case cannotPrepareEndpoint
    case unsynchronizedRevision
    case notFound
    case unauthorized
    case parseError(Data, Error)
}
