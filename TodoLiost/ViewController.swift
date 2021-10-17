//
//  ViewController.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 17.10.2021.
//

import UIKit
import CocoaLumberjack
class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        let sut = FileCache()
        
        
        let todoItem1 = TodoItem(text: "sample", priority: .important)
        let todoItem2 = TodoItem(text: "sample", priority: .normal)
        let todoItem3 = TodoItem(text: "sample", priority: .no)
        
        for item in [todoItem1, todoItem2, todoItem3]{
            sut.add(item)
        }
        
        for (i, item) in sut.todoItems.enumerated(){
            self.button.setTitle(item.text, for: .normal)
        }
        
    }
}

