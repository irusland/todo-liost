//
//  ViewController.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import UIKit
import CocoaLumberjack



class CustomCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ItemCell"
    
    let someLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        someLabel.translatesAutoresizingMaskIntoConstraints = false
        someLabel.numberOfLines = 0
        contentView.addSubview(someLabel)
        NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[V]-|",
            options: [],
            metrics: nil,
            views: ["V": someLabel]
        ).forEach { $0.isActive = true }
        NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[V]-|",
            options: [],
            metrics: nil,
            views: ["V": someLabel]
        ).forEach { $0.isActive = true }
    }
}



class MainViewController: UIViewController {
    static let storyboardId = "MainViewController"
    
    private let mainView: MainView
    
    private var fileCache: FileCache
    private let squaresViewController: SquaresViewController
    
    required init?(coder: NSCoder) {
        
        fileCache = FileCache()
        let todoItem1 = TodoItem(text: "sample", priority: .important)
        let todoItem2 = TodoItem(text: "sample", priority: .normal)
        let todoItem3 = TodoItem(text: "sample", priority: .no)
        
        for item in [todoItem1, todoItem2, todoItem3]{
            self.fileCache.add(item)
        }
        
        mainView = MainView(frame: UIScreen.main.bounds, fileCache: fileCache)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.backgroundColor = UIColor(hue: CGFloat(1), saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(0.1))
        
        squaresViewController = SquaresViewController(collectionViewLayout: CustomFlowLayout())
        squaresViewController.collectionView.register(CustomCell.self, forCellWithReuseIdentifier: CustomCell.reuseIdentifier)
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mainView)
        put(viewController: squaresViewController)
        addConstraints()
        
    }
    
    func put(viewController vc: UIViewController) {
        vc.view.frame = view.frame
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        guard let presentingViewController = self.presentingViewController else {
            return
        }
        
        squaresViewController.modalPresentationStyle = .formSheet
        squaresViewController.view.backgroundColor = .blue
        presentingViewController.present(squaresViewController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.squaresViewController.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    private func addConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
}

class MainView: UIView {
    private var fileCache: FileCache
    
    init(frame: CGRect, fileCache: FileCache) {
        self.fileCache = fileCache
        super.init(frame: frame)
        
        //        self.backgroundColor = .white
        //        self.translatesAutoresizingMaskIntoConstraints = false
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pressed(sender: UIButton!) {
        likeButton.setTitle(fileCache.todoItems[0].text, for: .normal)
        todoItemText.text = fileCache.todoItems[0].text
        //        fileCache.todoItems[0] = TodoItem(text: todoItemText.text, priority: .no)
        todoItemView.todoItemText.text = todoItemText.text
    }
    
    func setUpViews() {
        self.addSubview(contentView)
        self.addSubview(likeButton)
        self.addSubview(todoItemText)
        self.addSubview(todoItemView)
        
        likeButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: CGFloat(-10)),
            contentView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: CGFloat(-10)),
            
            likeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            likeButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            todoItemText.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            todoItemText.topAnchor.constraint(equalTo: self.topAnchor),
            todoItemText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: CGFloat(10)),
            todoItemText.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: CGFloat(-10)),
            todoItemText.heightAnchor.constraint(lessThanOrEqualToConstant: CGFloat(100)),
            
            todoItemView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            todoItemView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            todoItemView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            todoItemView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("liek", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let todoItemText: UITextView = {
        let todoItemText = UITextView(frame: .zero, textContainer: nil)
        todoItemText.backgroundColor = .yellow // visual debugging
        //        todoItemText.isScrollEnabled = false
        todoItemText.translatesAutoresizingMaskIntoConstraints = false
        return todoItemText
    }()
    
    let todoItemView: TodoItemUIView = {
        let todoItemView = TodoItemUIView()
        todoItemView.backgroundColor = .green
        todoItemView.translatesAutoresizingMaskIntoConstraints = false
        return todoItemView
    }()
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
            //            todoItemText.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: CGFloat(10)),
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
        todoItemText.backgroundColor = .gray
        todoItemText.translatesAutoresizingMaskIntoConstraints = false
        return todoItemText
    }()
    
    
}

//_____________________



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
        
        //if insertingIndexPaths.contains(itemIndexPath) {
        attributes?.alpha = 0.0
        attributes?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        //attributes?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        
        print(attributes)
        //}
        
        return attributes
    }
}

public struct Item {
    let color: UIColor
}

class SquaresViewController: UICollectionViewController {
    var items = [Item]()
    
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
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newLayout = (collectionView.collectionViewLayout == small ? big : small)

        collectionView.setCollectionViewLayout(newLayout, animated: true)
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(
                withReuseIdentifier: CustomCell.reuseIdentifier,
                for: indexPath
            )
        
        cell.backgroundColor = items[indexPath.item].color
        
        return cell
    }
    
    func addItem() {
        items.append(Item(color: .random()))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        for _ in 0...100 { addItem() }
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
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 20)
        
        super.init(collectionViewLayout: layout)
        
        useLayoutToLayoutNavigationTransitions = false
        
        items = (0...50).map { _ in Item(color: .random()) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let newLayout = (collectionView.collectionViewLayout == small ? big : small)
//
//        collectionView.setCollectionViewLayout(newLayout, animated: true)
//    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
//
//        DDLogInfo("TAP \(indexPath) \(navController) \(viewController)")
//
        let bigVC = BigViewController()
        
        bigVC.items = items
        
        presentingViewController?.navigationController?
            .pushViewController(bigVC, animated: true)
    }
}


class BigViewController : SquaresViewController {
    init() {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 100, height: 100)
        
        super.init(collectionViewLayout: layout)
        
        useLayoutToLayoutNavigationTransitions = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presentingViewController?.navigationController?.popViewController(animated: true)
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
