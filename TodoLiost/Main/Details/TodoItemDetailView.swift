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
            guard let touch = touches.first else {
                return
            }
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
        let colorMap: [Int: UIColor] = [
            0: .white,
            1: .orange,
            2: .red
        ]
        importancySelector.selectedSegmentTintColor = colorMap[index]
    }

    @objc func importancySelectorTouched(sender: UISegmentedControl) {
        refreshImportancySelector()
    }

    let importancySelectorLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Priority"
        return label
    }()

    let importancySelector: UISegmentedControl = {
        let items = [
            UIImage(systemName: "bookmark.slash"),
            UIImage(systemName: "exclamationmark"),
            UIImage(systemName: "flame.fill")
        ]
        var control = UISegmentedControl(items: items as [Any])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(importancySelectorTouched), for: .valueChanged)
        control.backgroundColor = .lightGray
        return control
    }()

    func colorPickerTouched(_ sender: ColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        DDLogInfo("Custom color = \(color)")

        todoItemColor = color
        colorLabel.backgroundColor = color
        self.dismiss(animated: true)
    }

    let storage: ItemStorage
    var itemPresented: TodoItem

    var todoItemColor: UIColor?

    var colorPickerController: ColorPickerController

    @objc func deleteItem() {
        DDLogInfo("Deleted")

        _ = storage.remove(by: itemPresented.id)
        DDLogInfo("after delete: \(storage.todoItems)")

        if let fvc = self.presentingViewController as? UICollectionViewController {
            self.dismiss(animated: true) {
                fvc.collectionView.reloadData()
            }
        }
    }

    @objc func saveItem() {
        DDLogInfo("Saving item")

        var deadline: Date?
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

        _ = storage.update(at: itemPresented.id, todoItem: newItem)
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
                    button.widthAnchor.constraint(equalToConstant: 70.0)
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
        if !datePickerSwitch.isOn {
            datePickerHeightConstraint?.constant = 0
        } else {
            datePickerHeightConstraint?.constant = 400
        }

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
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
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    init(rootViewController: UIViewController, storage: ItemStorage) {
        DDLogInfo("ROOT Init Details view controller")
        self.storage = storage
        itemPresented = TodoItem(text: "")
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
        importancySelector.selectedSegmentIndex = item.priority.number
        refreshImportancySelector()
        DDLogInfo("Detail Item updated to \(item)")
    }

    let scrollViewContainer: UIScrollView = {
        var view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let bottomLine: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: CGFloat(1)).isActive = true
        view.backgroundColor = .black
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "todoDetailsView"

        view.addSubview(deleteButton)
        view.addSubview(saveButton)

        view.addSubview(scrollViewContainer)

        scrollViewContainer.addSubview(textView)

        scrollViewContainer.addSubview(datePickerSwitch)
        scrollViewContainer.addSubview(dateLabel)
        scrollViewContainer.addSubview(datePicker)

        scrollViewContainer.addSubview(colorLabel)
        scrollViewContainer.addSubview(colorScrollView)
        colorScrollView.addSubview(colorStackView)

        scrollViewContainer.addSubview(importancySelectorLabel)
        scrollViewContainer.addSubview(importancySelector)

        scrollViewContainer.addSubview(bottomLine)

        setupViews()
    }

    var datePickerHeightConstraint: NSLayoutConstraint?

    func setupViews() {
        textView.delegate = self
        heightConstraint = textView.heightAnchor.constraint(equalToConstant: 30.0)
        heightConstraint.isActive = true

        let lineHeight = CGFloat(30)

        var constraints = [NSLayoutConstraint]()

        constraints.append(contentsOf: [
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            scrollViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            scrollViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            scrollViewContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollViewContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            textView.centerXAnchor.constraint(equalTo: scrollViewContainer.centerXAnchor),
            textView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor),
            textView.leadingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            textView.trailingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),

            importancySelectorLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: CGFloat(10)),
            importancySelectorLabel.heightAnchor.constraint(equalToConstant: lineHeight),
            importancySelectorLabel.leadingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            importancySelectorLabel.widthAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.widthAnchor, multiplier: CGFloat(0.5)),

            importancySelector.topAnchor.constraint(equalTo: importancySelectorLabel.topAnchor),
            importancySelector.heightAnchor.constraint(equalTo: importancySelectorLabel.heightAnchor),
            importancySelector.leadingAnchor.constraint(equalTo: importancySelectorLabel.trailingAnchor),
            importancySelector.trailingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),

            dateLabel.topAnchor.constraint(equalTo: importancySelectorLabel.bottomAnchor, constant: CGFloat(10)),
            dateLabel.leadingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            dateLabel.heightAnchor.constraint(equalToConstant: lineHeight),

            datePickerSwitch.topAnchor.constraint(equalTo: importancySelectorLabel.bottomAnchor, constant: CGFloat(10)),
            datePickerSwitch.trailingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),

            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            datePicker.trailingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),

            colorLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: CGFloat(10)),
            colorLabel.leadingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            colorLabel.widthAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.widthAnchor, multiplier: CGFloat(0.5)),

            bottomLine.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: CGFloat(10)),
            bottomLine.leadingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            bottomLine.trailingAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.trailingAnchor, constant: -10)

        ])

        datePickerHeightConstraint = datePicker.heightAnchor.constraint(equalToConstant: 0)

        if let constraint = datePickerHeightConstraint {
            constraints.append(constraint)
        }

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
            colorStackView.heightAnchor.constraint(equalTo: colorScrollView.heightAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(showColorPicker))
        colorLabel.addGestureRecognizer(tap)

        let hideKeyBoardTap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        hideKeyBoardTap.cancelsTouchesInView = false

        view.addGestureRecognizer(hideKeyBoardTap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = bottomLine.frame.size.height
        let pos = bottomLine.frame.origin.y
        let sizeOfContent = height + pos + 10
        self.scrollViewContainer.contentSize.height = sizeOfContent
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    var isFrameReducedByKeyboard: Bool = false

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !isFrameReducedByKeyboard {
                isFrameReducedByKeyboard = true
                view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardSize.height)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if isFrameReducedByKeyboard {
                isFrameReducedByKeyboard = false
                view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height + keyboardSize.height)
            }
        }
    }

    @objc func addTapped() {
        DDLogInfo("addTapped")
    }
    @objc func playTapped() {
        DDLogInfo("playTapped")
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
