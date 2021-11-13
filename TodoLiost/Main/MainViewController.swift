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

    private var fileCache: FileCache
    private let squaresViewController: SquaresViewController
    private let todoItemDetailViewController: TodoItemDetailViewController

    required init?(coder: NSCoder) {

        fileCache = FileCache()
        let todoItem1 = TodoItem(text: "sample", priority: .important, color: .red)
        let todoItem2 = TodoItem(text: "sample", priority: .normal, color: .green)
        let todoItem3 = TodoItem(text: "sample", priority: .no, color: .blue)

        for item in [todoItem1, todoItem2, todoItem3] {
            self.fileCache.add(item)
        }
        todoItemDetailViewController = TodoItemDetailViewController(rootViewController: UIViewController(), fileCache: fileCache)

        squaresViewController = SmallViewController(with: fileCache, todoItemDetailViewController)

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
