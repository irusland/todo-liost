//
//  TodoItemEditView.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 30.10.2021.
//

import Foundation
import UIKit
import CocoaLumberjack

class TodoItemDetailViewController: UINavigationController {
    let fileCache: FileCache
    var itemPresented: TodoItem
    
    var todoItemColor: UIColor?
    
    
    @objc func deleteItem() {
        DDLogInfo("Deleted")
        
        fileCache.remove(by: itemPresented.id)
        DDLogInfo("after delete: \(fileCache.todoItems)")
        
        if let fvc = self.presentingViewController as? UICollectionViewController {
            self.dismiss(animated: true) {
                fvc.collectionView.reloadData()
            }
        }
    }
    
    @objc func saveItem() {
        DDLogInfo("Saving item")
        
        let newItem = TodoItem(
            id: itemPresented.id,
            text: textView.text,
//            priority: ,
//            deadLine: T##Date?,
            color: todoItemColor
        )
        
        let _ = fileCache.update(at: itemPresented.id, todoItem: newItem)
        DDLogInfo("Updated: \(newItem)")
        
        
        if let fvc = self.presentingViewController as? UICollectionViewController {
            self.dismiss(animated: true) {
                fvc.collectionView.reloadData()
            }
        }
    }
    
    let deleteButton: UIButton = {
        var button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        return button
    }()
    
    
    let saveButton: UIButton = {
        var button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveItem), for: .touchUpInside)
        return button
    }()
    
    var heightConstraint: NSLayoutConstraint!
    var maxHeight: CGFloat = 0
    var maxLines: CGFloat = 5
    
    var textView: UITextView = {
        var textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .gray

        
        return textView
    }()

    init(rootViewController: UIViewController, fileCache: FileCache) {
        DDLogInfo("ROOT Init Details view controller")
        self.fileCache = fileCache
        itemPresented = fileCache.todoItems[0]
        
        super.init(nibName: nil, bundle: nil)
        
//        self.viewControllers = [rootViewController]
//
//        delegate = self
    }
    
    init(fileCache: FileCache) {
        DDLogInfo("Init Details view controller")
        self.fileCache = fileCache
        itemPresented = fileCache.todoItems[0]
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadItem(item: TodoItem) {
        itemPresented = item
        todoItemColor = item.color
        self.view.backgroundColor = item.color
        textView.text = item.text
        DDLogInfo("Detail Item updated to \(item)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        view.addSubview(deleteButton)
        view.addSubview(saveButton)
        
        setupViews()
    }
    
    func setupViews() {
        textView.delegate = self
        heightConstraint = textView.heightAnchor.constraint(equalToConstant: 30.0)
        heightConstraint.isActive = true
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(50)),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: CGFloat(-20)),
//            textView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: CGFloat(1/5))
//            textView.heightAnchor.constraint(equalToConstant: CGFloat(200)),
            
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate(constraints)
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playTapped))
        navigationItem.rightBarButtonItems = [add, play]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        
        
        saveButton.layer.cornerRadius = 0.5 * saveButton.bounds.size.width
        saveButton.clipsToBounds = true
    }
    
    @objc func addTapped() {
        DDLogInfo("addTapped")
    }
    @objc func playTapped() {
        DDLogInfo("playTapped")
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        heightConstraint.constant = textView.contentSize.height
        super.viewWillAppear(animated)
    }
}

extension TodoItemDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let numberOfLines = textView.contentSize.height/(textView.font?.lineHeight)!
        
        if let lineHeight = textView.font?.lineHeight {
            maxHeight = maxLines * lineHeight
        }
        
        if numberOfLines > maxLines {
            self.heightConstraint.constant = maxHeight
        } else {
            self.heightConstraint.constant = textView.contentSize.height
        }
        textView.layoutIfNeeded()
    }
}
