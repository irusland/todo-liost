//
//  ViewController.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import UIKit
import CocoaLumberjack



class TodoItemCell: UICollectionViewCell {
    static let reuseIdentifier = "ItemCell"
    
    public let todoItemText: UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(todoItemText)
        todoItemText.frame = bounds

        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            
//            todoItemText.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        NSLayoutConstraint.activate(constraints)
        
        backgroundColor = .white

        layer.borderWidth = 2
    }
}



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
        
        for item in [todoItem1, todoItem2, todoItem3]{
            self.fileCache.add(item)
        }
        todoItemDetailViewController = TodoItemDetailViewController(rootViewController: UIViewController(), fileCache: fileCache)
        
        squaresViewController = SmallViewController(with: fileCache, todoItemDetailViewController)
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        put(viewController: squaresViewController)
        addConstraints()
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
    
    private func addConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
}


class TodoItemUIView: UIView {
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpViews() {
        self.addSubview(todoItemText)
        self.addSubview(priotiry)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            
            todoItemText.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            todoItemText.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            todoItemText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: CGFloat(10)),
            todoItemText.heightAnchor.constraint(lessThanOrEqualToConstant: CGFloat(100)),
            
            priotiry.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            priotiry.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            priotiry.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            priotiry.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    let priotiry: UIImageView = {
        let priotiry = UIImageView(image: UIImage(named: "UIBarButtonItem.SystemItem.action"))
        let image = UIImage(named: "UIBarButtonItem.SystemItem.action")
        priotiry.image = image
        priotiry.translatesAutoresizingMaskIntoConstraints = false
        return priotiry
    }()
    
    let todoItemText: UITextField = {
        let todoItemText = UITextField()
        todoItemText.backgroundColor = .white
        todoItemText.translatesAutoresizingMaskIntoConstraints = false
        return todoItemText
    }()
    
    
}

class CustomFlowLayout : UICollectionViewFlowLayout {
    var insertingIndexPaths = [IndexPath]()
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        insertingIndexPaths.removeAll()
        
        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate,
               update.updateAction == .insert {
                insertingIndexPaths.append(indexPath)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        insertingIndexPaths.removeAll()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if insertingIndexPaths.contains(itemIndexPath) {
            attributes?.alpha = 0.0
            attributes?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            attributes?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        }
        
        return attributes
    }
}

class SquaresViewController: UICollectionViewController {
    var fileCache: FileCache
    var todoItemDetailViewController: TodoItemDetailViewController
    
    init(collectionViewLayout layout: UICollectionViewLayout, _ fileCache: FileCache, _ todoItemDetailViewController: TodoItemDetailViewController) {
        self.fileCache = fileCache
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
    
    var big: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 150, height: 150)
        
        return layout
    }()
    
    func showItemDetails(_ indexPath: IndexPath) {
        let itemToShow = fileCache.todoItems[indexPath.item]
        todoItemDetailViewController.loadItem(item: itemToShow)
        DDLogInfo("Presenting todo item details")
        
        show(todoItemDetailViewController, sender: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(indexPath: indexPath)
    }
    
    func configureContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                self.showItemDetails(indexPath)
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { (_) in
                let itemSelected = self.fileCache.todoItems[indexPath.item]
                let _ = self.fileCache.remove(by: itemSelected.id)
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
        DDLogInfo("Item count \(fileCache.todoItems.count)")
        return fileCache.todoItems.count
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
        
        let item = fileCache.todoItems[indexPath.item]

        todoCell.layer.borderColor = item.color?.cgColor
        todoCell.todoItemText.text = item.text
        return todoCell
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(in: 0...1),
            green: .random(in: 0...1),
            blue:  .random(in: 0...1),
            alpha: 1.0
        )
    }
}

class SmallViewController : SquaresViewController {
    init(with fileCache: FileCache, _ todoItemDetailViewController: TodoItemDetailViewController) {
        let layout = CustomFlowLayout()
//        layout.itemSize = CGSize(width: 50, height: 20)
        
        super.init(collectionViewLayout: layout, fileCache, todoItemDetailViewController)

        useLayoutToLayoutNavigationTransitions = false

//        view.translatesAutoresizingMaskIntoConstraints = false
        setupSubviews()
    }
    
    @objc func addItem() {
        let todoItem = TodoItem(text: "")
        DDLogInfo("Generatin new item \(todoItem)")
        fileCache.add(todoItem)
        collectionView.reloadData()
        todoItemDetailViewController.loadItem(item: todoItem)
        show(todoItemDetailViewController, sender: self)
    }
    
    let addButton : UIButton = {
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
    }
    
    func setupSubviews() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat(10)),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            addButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
//            view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate(constraints)
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


extension SquaresViewController : UINavigationControllerDelegate {
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
