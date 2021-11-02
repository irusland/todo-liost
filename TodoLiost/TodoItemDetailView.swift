//
//  TodoItemEditView.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 30.10.2021.
//

import Foundation
import UIKit
import CocoaLumberjack

class UIDeselectableSegmentedControl: UISegmentedControl {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let previousSelectedSegmentIndex = self.selectedSegmentIndex
        
        super.touchesEnded(touches, with: event)
        
        if previousSelectedSegmentIndex == self.selectedSegmentIndex {
            
            self.selectedSegmentIndex = UISegmentedControl.noSegment
            let touch = touches.first!
            let touchLocation = touch.location(in: self)
            if bounds.contains(touchLocation) {
                self.sendActions(for: .valueChanged)
            }
        }
    }
}

class TodoItemDetailViewController: UINavigationController, ColorPickerDelegate {
    func refreshImportancySelector() {
        let index = importancySelector.selectedSegmentIndex
        DDLogInfo("Importancy refresh [\(index)]")
        let colorMap: [Int:UIColor] = [
            0: .white,
            1: .orange,
            2: .red,
        ]
        importancySelector.selectedSegmentTintColor = colorMap[index]
    }
    
    @objc func importancySelectorTouched(sender: UISegmentedControl) {
        refreshImportancySelector()
    }
    
    let importancySelector: UISegmentedControl = {
        let items = [
            UIImage(systemName: "bookmark.slash"),
            UIImage(systemName: "exclamationmark"),
            UIImage(systemName: "flame.fill"),
        ]
        var control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(importancySelectorTouched), for: .valueChanged)
        control.backgroundColor = .lightGray
        return control
    }()
    
    func ColorColorPickerTouched(sender: ColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        DDLogInfo("Custom color = \(color)")
        
        todoItemColor = color
        colorLabel.backgroundColor = color
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
            priority: .fromInt(importancySelector.selectedSegmentIndex),
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
    
    @objc func showColorPicker() {
        present(colorPickerController, animated: true)
    }
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Color"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    
    @objc func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 0 {
            DDLogInfo("Custom color button pressed, opening color picker")
            showColorPicker()
        } else {
            DDLogInfo("Random color button pressed")
            let color = btnsendtag.backgroundColor
            todoItemColor = color
            colorLabel.backgroundColor = color
        }
    }
    
    let colorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        for idx in 0...50 {
            let button = UIButton()
            button.backgroundColor = UIColor.random()
            if idx == 0 {
                let boldConfig = UIImage.SymbolConfiguration(weight: .bold)
                let boldSearch = UIImage(systemName: "pencil.circle", withConfiguration: boldConfig)
                button.setImage(boldSearch, for: .normal)
                button.backgroundColor = .white
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: 70.0),
                ])
            }
            button.setTitle("\(idx)", for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.tag = idx

            stackView.addArrangedSubview(button)
            
//            NSLayoutConstraint.activate([
//                button.widthAnchor.constraint(equalToConstant: 50.0),
//                button.heightAnchor.constraint(equalToConstant: 50.0),
//            ])
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
        textView.backgroundColor = .lightGray
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
        colorLabel.backgroundColor = item.color ?? .clear
        textView.text = item.text
        datePickerSwitch.setOn(item.deadLine != nil, animated: true)
        refreshDatePickerState()
        importancySelector.selectedSegmentIndex = item.priority.toInt()
        refreshImportancySelector()
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
        
        view.addSubview(importancySelector)
        
        
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
            colorLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: CGFloat(0.5)),
            
            importancySelector.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: CGFloat(10)),
            importancySelector.heightAnchor.constraint(equalTo: colorLabel.heightAnchor),
            importancySelector.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            importancySelector.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
            
            
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
            colorScrollView.topAnchor.constraint(equalTo: colorLabel.topAnchor),
            colorScrollView.leadingAnchor.constraint(equalTo: colorLabel.trailingAnchor, constant: 8.0),
            colorScrollView.trailingAnchor.constraint(equalTo: safeG.trailingAnchor, constant: -8.0),
            colorScrollView.heightAnchor.constraint(equalTo: colorLabel.heightAnchor, multiplier: CGFloat(1)),
            
            colorStackView.topAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.topAnchor),
            colorStackView.leadingAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.leadingAnchor),
            colorStackView.trailingAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.trailingAnchor),
            colorStackView.heightAnchor.constraint(equalTo: colorScrollView.heightAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(showColorPicker))
        colorLabel.addGestureRecognizer(tap)
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
