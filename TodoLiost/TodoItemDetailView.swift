//
//  TodoItemEditView.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 30.10.2021.
//

import Foundation
import UIKit
import CocoaLumberjack

class TodoItemDetailViewController: UIViewController {
    let fileCache: FileCache
    var itemPresented: TodoItem
    
    var textView: UIText
    
    init(fileCache: FileCache) {
        DDLogInfo("Init Details view controller")
        self.fileCache = fileCache
        itemPresented = fileCache.todoItems[0]
        super.init()
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        fileCache = FileCache()
        itemPresented = TodoItem(text: "asd")
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadItem(item: TodoItem) {
        itemPresented = item
        self.view.backgroundColor = item.color
        DDLogInfo("Detail Item updated to \(item)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(<#T##view: UIView##UIView#>)
    }
}
