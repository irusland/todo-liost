//
//  TodoItemCell.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 12.11.2021.
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

            todoItemText.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            todoItemText.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
            todoItemText.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: CGFloat(10)),

            priorityIcon.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            priorityIcon.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
            priorityIcon.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: CGFloat(10)),

            dateLabel.leadingAnchor.constraint(equalTo: todoItemText.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: todoItemText.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: todoItemText.bottomAnchor, constant: CGFloat(10)),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat(-10))

        ])

        NSLayoutConstraint.activate(constraints)

        backgroundColor = .white

        layer.borderWidth = 2
    }
}
