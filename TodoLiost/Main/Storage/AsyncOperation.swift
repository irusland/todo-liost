//
//  AsyncOperation.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 21.11.2021.
//

import Foundation

class AsyncOperation: Operation {

    private var _isExecuting = false
    private var _isFinished = false

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }

        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        main()
        didChangeValue(forKey: "isExecuting")
    }

    override func main() {
        // NOTE: should be overriden
        finish()
    }

    func finish() {
        willChangeValue(forKey: "isFinished")
        _isFinished = true
        didChangeValue(forKey: "isFinished")
    }

    override var isAsynchronous: Bool {
        return true
    }

    override var isExecuting: Bool {
        return _isExecuting
    }

    override var isFinished: Bool {
        return _isFinished
    }
}
