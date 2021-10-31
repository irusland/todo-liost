//
//  TodoItemEditView.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 30.10.2021.
//

import Foundation
import UIKit
import CocoaLumberjack

class TodoItemDetailViewController: UINavigationController, ColorPickerDelegate {
    func ColorColorPickerTouched(sender: ColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        DDLogInfo("Custom color = \(color)")
        
        todoItemColor = color
        colorLabel.layer.borderColor = color.cgColor
        if let fvc = self.presentingViewController as? UICollectionViewController {
            self.dismiss(animated: true)
        }
    }
    
    let fileCache: FileCache
    var itemPresented: TodoItem
    
    var todoItemColor: UIColor?
    
    var colorPickerController: ColorPickerController
    
    @objc func deleteItem() {
        DDLogInfo("Deleted")
        
        let _ = fileCache.remove(by: itemPresented.id)
        DDLogInfo("after delete: \(fileCache.todoItems)")
        
        if let fvc = self.presentingViewController as? UICollectionViewController {
            self.dismiss(animated: true) {
                fvc.collectionView.reloadData()
            }
        }
    }
    
    @objc func saveItem() {
        DDLogInfo("Saving item")
        
        var deadline: Date? = nil
        if datePickerSwitch.isOn {
            deadline = datePicker.date
        }
        
        let newItem = TodoItem(
            id: itemPresented.id,
            text: textView.text,
//            priority: ,
            deadLine: deadline,
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
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Color"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.borderWidth = 2
        return label
    }()
    
    @objc func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 0 {
            DDLogInfo("Custom color button pressed, opening color picker")
            present(colorPickerController, animated: true)
        }
    }
    
    let colorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        for idx in 0...10 {
            let button = UIButton()
            button.backgroundColor = .gray
            button.setTitle("\(idx)", for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.tag = idx
            // add button to row stack view
            stackView.addArrangedSubview(button)
            
            // buttons should be 50x50
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 50.0),
                button.heightAnchor.constraint(equalToConstant: 50.0),
            ])
        }
        
       return stackView
    }()
    
    let colorScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Deadline"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func refreshDatePickerState() {
        datePicker.isHidden = !datePickerSwitch.isOn
    }
    
    @objc func dateSwitchChanged() {
        refreshDatePickerState()
    }
    
    let datePickerSwitch: UISwitch = {
        let dateSwitch = UISwitch()
        dateSwitch.translatesAutoresizingMaskIntoConstraints = false
        dateSwitch.addTarget(self, action: #selector(dateSwitchChanged), for: .valueChanged)
        return dateSwitch
    }()
    
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
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    init(rootViewController: UIViewController, fileCache: FileCache) {
        DDLogInfo("ROOT Init Details view controller")
        self.fileCache = fileCache
        itemPresented = fileCache.todoItems[0]
        colorPickerController = ColorPickerController()
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadItem(item: TodoItem) {
        itemPresented = item
        todoItemColor = item.color
        colorLabel.layer.borderColor = item.color?.cgColor
//        self.view.backgroundColor = item.color
        textView.text = item.text
        datePickerSwitch.setOn(item.deadLine != nil, animated: true)
        refreshDatePickerState()
        DDLogInfo("Detail Item updated to \(item)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        view.addSubview(deleteButton)
        view.addSubview(saveButton)
        
        view.addSubview(datePickerSwitch)
        view.addSubview(dateLabel)
        view.addSubview(datePicker)
        
        view.addSubview(colorLabel)
        view.addSubview(colorScrollView)
        colorScrollView.addSubview(colorStackView)
        
        
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
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: CGFloat(-20)),
//            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(100)),
//            textView.heightAnchor.constraint(equalToConstant: CGFloat(200)),
            
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: CGFloat(10)),
            dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
//            dateLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: CGFloat(-20)),
        
            datePickerSwitch.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: CGFloat(10)),
            datePickerSwitch.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: CGFloat(10)),
            datePicker.heightAnchor.constraint(equalTo: dateLabel.heightAnchor),
            
            
            colorLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: CGFloat(10)),
            colorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            colorLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
        ])
        
        NSLayoutConstraint.activate(constraints)
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playTapped))
        navigationItem.rightBarButtonItems = [add, play]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        
        
        colorPickerController.colorPicker.delegate = self
        
        let safeG = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
//            // constrain label
//            //  50-pts from top
//            //  80% of the width
//            //  centered horizontally
//            label.topAnchor.constraint(equalTo: safeG.topAnchor, constant: 50.0),
//            label.widthAnchor.constraint(equalTo: safeG.widthAnchor, multiplier: 0.8),
//            label.centerXAnchor.constraint(equalTo: safeG.centerXAnchor),
//
            // constrain scrollView
            //  50-pts from bottom of label
            //  Leading and Trailing to safe-area with 8-pts "padding"
            //  Bottom to safe-area with 8-pts "padding"
            colorScrollView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 50.0),
            colorScrollView.leadingAnchor.constraint(equalTo: safeG.leadingAnchor, constant: 8.0),
            colorScrollView.trailingAnchor.constraint(equalTo: safeG.trailingAnchor, constant: -8.0),
            colorScrollView.bottomAnchor.constraint(equalTo: safeG.bottomAnchor, constant: -8.0),
            
            // constrain vertical stack view to scrollView Content Layout Guide
            //  8-pts all around (so we have a little "padding")
            colorStackView.topAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.topAnchor, constant: 8.0),
            colorStackView.leadingAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.leadingAnchor, constant: 8.0),
            colorStackView.trailingAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.trailingAnchor, constant: -8.0),
            colorStackView.bottomAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.bottomAnchor, constant: -8.0),
            
        ])

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
