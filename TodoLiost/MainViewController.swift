//
//  ViewController.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import UIKit
import CocoaLumberjack
class MainViewController: UIViewController {
    private let mainView: MainView
    
    private var fileCache: FileCache

    
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

        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        self.fileCache = FileCache()
        
        super.viewDidLoad()
        view.addSubview(mainView)
        addConstraints()

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
        
    }
    
    func setUpViews() {
        self.addSubview(contentView)
        self.addSubview(likeButton)
        likeButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: [
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: CGFloat(-10)),
            contentView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: CGFloat(-10)),
            likeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            likeButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("liek", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}
