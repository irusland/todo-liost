//
//  SquaresViewController.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 12.11.2021.
//

import UIKit
import CocoaLumberjack
import Foundation

class SquaresViewController: UICollectionViewController, NotifierDelegate {
    var storage: PresistantStorage
    var todoItemDetailViewController: TodoItemDetailViewController

    var layoutTag: LayoutSize = .small

    init(collectionViewLayout layout: UICollectionViewLayout, _ storage: PresistantStorage, _ todoItemDetailViewController: TodoItemDetailViewController) {
        self.storage = storage
        self.todoItemDetailViewController = todoItemDetailViewController
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var small: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()

        layout.itemSize = CGSize(width: 75, height: 75)

        return layout
    }()

    var mid: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()

        layout.itemSize = CGSize(width: 150, height: 150)

        return layout
    }()

    var big: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()

        layout.itemSize = CGSize(width: 300, height: 150)

        return layout
    }()

    func showItemDetails(_ indexPath: IndexPath) {
        let itemToShow = storage.todoItems[indexPath.item]
        todoItemDetailViewController.loadItem(item: itemToShow)
        DDLogInfo("Presenting todo item details for \(indexPath)")

        show(todoItemDetailViewController, sender: self)
    }

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(indexPath: indexPath)
    }

    func configureContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in

            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                self.showItemDetails(indexPath)
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { (_) in
                let itemSelected = self.storage.todoItems[indexPath.item]
                _ = self.storage.remove(by: itemSelected.id)
                self.collectionView.reloadData()
            }

            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit, delete])

        }
        return context
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        DDLogInfo("Item count \(storage.todoItems.count)")
        return storage.todoItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        let newLayout = (collectionView.collectionViewLayout == small ? big : small)
        //        collectionView.setCollectionViewLayout(newLayout, animated: true)
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TodoItemCell.reuseIdentifier,
            for: indexPath
        )
        guard let todoCell = cell as? TodoItemCell else {
            return cell
        }

        let item = storage.todoItems[indexPath.item]

        todoCell.layer.borderColor = item.color?.cgColor
        todoCell.todoItemText.text = item.text
        todoCell.dateLabel.text = nil
        if let deadLine = item.deadLine {
            todoCell.dateLabel.text = deadLine.string
        }
        return todoCell
    }
    
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresher = UIRefreshControl()
        self.collectionView.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView.addSubview(refresher)
        self.collectionView.refreshControl = refresher
    }
    
    func operationFinished() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.stopRefresher()
        }
    }
    
    @objc func loadData() {
        self.collectionView.refreshControl?.beginRefreshing()
        DDLogInfo("Refreshing Started")
        
        storage.sync(notifierDelegate: self)
    }
    
    func stopRefresher() {
        self.collectionView.refreshControl?.endRefreshing()
        DDLogInfo("Refreshing Ended")
    }
}

class SmallViewController: SquaresViewController {
    @objc func sizeSliderChange(sender: UISlider) {
        let step: Float = 1
        let currentValue = Int(round((sender.value - sender.minimumValue) / step))

        layoutTag = LayoutSize(rawValue: currentValue) ?? .small

        collectionView.reloadData()
    }

    var sizeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 2
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    init(with storage: PresistantStorage, _ todoItemDetailViewController: TodoItemDetailViewController) {
        let layout = UICollectionViewFlowLayout.init()
        super.init(collectionViewLayout: layout, storage, todoItemDetailViewController)

        useLayoutToLayoutNavigationTransitions = false
    }

    @objc func addItem() {
        let todoItem = TodoItem(text: "")
        DDLogInfo("Generatin new item \(todoItem)")
        storage.add(todoItem)
        collectionView.reloadData()
        todoItemDetailViewController.loadItem(item: todoItem)
        show(todoItemDetailViewController, sender: self)
    }

    let addButton: UIButton = {
        let button = UIButton()

        button.setTitle("+", for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.setTitleShadowColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.borderWidth = 2

        button.layer.cornerRadius = 10
        button.clipsToBounds = true

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(addButton)
        view.addSubview(sizeSlider)

        setupSubviews()
    }

    func setupSubviews() {
        var constraints = [NSLayoutConstraint]()

        constraints.append(contentsOf: [
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            sizeSlider.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: CGFloat(-10)),
            sizeSlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            sizeSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate(constraints)

        sizeSlider.addTarget(self, action: #selector(sizeSliderChange), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showItemDetails(indexPath)
    }

    override func viewDidAppear(_ animated: Bool) {
        DDLogInfo("Collection Appear")
        collectionView.reloadData()
    }
}

extension SquaresViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let squaresVC = viewController as? SquaresViewController else { return }

        squaresVC.collectionView?.delegate = squaresVC
        squaresVC.collectionView?.dataSource = squaresVC
    }
}

enum LayoutSize: Int {
    case small = 0
    case mid = 1
    case big = 2
}

extension SquaresViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellAtIndex = self.collectionView(collectionView, cellForItemAt: indexPath) as? TodoItemCell
        var width = CGFloat(75)
        var height = CGFloat(75)
        if let cell = cellAtIndex {
            height = cell.todoItemText.text?.height(withConstrainedWidth: width, font: cell.todoItemText.font) ?? height
            height += 30
            height += cell.dateLabel.text?.height(withConstrainedWidth: width, font: cell.dateLabel.font) ?? 0

        } else {

        }

        switch layoutTag {
        case .small:
            width = ((collectionView.frame.width - 20)/3)
            DDLogInfo("Small cell width:\(width) height:\(height)")
        case .mid:
            width = ((collectionView.frame.width - 20)/2)
            DDLogInfo("Mid cell width:\(width) height:\(height)")
        case .big:
            width = ((collectionView.frame.width - 20))
            DDLogInfo("Big cell width:\(width) height:\(height)")
        }
        return CGSize(width: width, height: height)
    }
}
