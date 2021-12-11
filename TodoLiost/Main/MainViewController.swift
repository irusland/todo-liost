//
//  ViewController.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import UIKit
import CocoaLumberjack

class MainViewController: UIViewController {
    static let storyboardId = "MainViewController"

    private var storage: PresistantStorage
    private let squaresViewController: SquaresViewController
    private let todoItemDetailViewController: TodoItemDetailViewController

    required init?(coder: NSCoder) {

        let auth = Auth()
        let connector = BackendConnector(auth: auth)
        var cloudStorage = CloudStorage(connector: connector)
        let fileCache = FileCache()
        storage = PresistantStorage(fileCache: fileCache, cloudStorage: cloudStorage)

        todoItemDetailViewController = TodoItemDetailViewController(rootViewController: UIViewController(), storage: storage)

        squaresViewController = SmallViewController(with: storage, todoItemDetailViewController, authentificator: auth, connector: connector)
        storage.notifierDelegate = squaresViewController
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func put(viewController vc: UIViewController) {
        vc.view.frame = view.bounds
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        squaresViewController.modalPresentationStyle = .fullScreen
        squaresViewController.collectionView.register(TodoItemCell.self, forCellWithReuseIdentifier: TodoItemCell.reuseIdentifier)

        show(squaresViewController, sender: self)
    }
}
