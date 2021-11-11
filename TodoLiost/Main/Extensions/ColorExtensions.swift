//
//  ColorExtensions.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 12.11.2021.
//

import UIKit


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
