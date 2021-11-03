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
    
    let dateLabel: UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    public let todoItemText: UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.numberOfLines = 0
        return textView
    }()
    
    let priorityIcon: UIImageView = {
        let icon = UIImage(named: "flame.fill")
        let image = UIImageView(image: icon)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
        contentView.addSubview(priorityIcon)
        contentView.addSubview(dateLabel)
        

        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [

            todoItemText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat(10)),
            todoItemText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: CGFloat(-10)),
            todoItemText.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat(10)),
            
            priorityIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat(10)),
            priorityIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: CGFloat(-10)),
            priorityIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat(10)),
            
            dateLabel.leadingAnchor.constraint(equalTo: todoItemText.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: todoItemText.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: todoItemText.bottomAnchor, constant: CGFloat(10)),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: CGFloat(-10)),
            
            
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
    
    var layoutTag: LayoutSize = .small
    
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
        let itemToShow = fileCache.todoItems[indexPath.item]
        todoItemDetailViewController.loadItem(item: itemToShow)
        DDLogInfo("Presenting todo item details for \(indexPath)")
        
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

    func getStringDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: date)
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
        todoCell.dateLabel.text = nil
        if let deadLine = item.deadLine {
            todoCell.dateLabel.text = self.getStringDate(date: deadLine)
        }
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

    init(with fileCache: FileCache, _ todoItemDetailViewController: TodoItemDetailViewController) {
        let layout = CustomFlowLayout()
        
        super.init(collectionViewLayout: layout, fileCache, todoItemDetailViewController)

        useLayoutToLayoutNavigationTransitions = false
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
            sizeSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
            DDLogInfo(">>> GOT cell \(indexPath) \(cell)")
        } else {
            DDLogInfo(">>> NO cell at \(indexPath)")
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

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
