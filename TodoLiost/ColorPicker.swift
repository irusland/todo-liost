//
//  ColorPicker.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 31.10.2021.
//

import Foundation
import UIKit
import CocoaLumberjack

@objc internal protocol ColorPickerDelegate {
    func ColorColorPickerTouched(sender:ColorPicker, color:UIColor, point:CGPoint, state:UIGestureRecognizer.State)
}

@objc internal protocol ColorPickerIntermediateDelegate {
    func ColorColorPickerTouchBegin(sender:ColorPicker, color:UIColor, point:CGPoint, state:UIGestureRecognizer.State)
}


class ColorPickerController: UIViewController, ColorPickerIntermediateDelegate {
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        
        return hexString
    }
    
    func ColorColorPickerTouchBegin(sender: ColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        DDLogInfo("Color picker Controller touch beigan")
        chosenColorView.backgroundColor = color
        hexLabel.text = hexStringFromColor(color: color)
    }
    
    var hexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center;
        return label
    }()
    
    var chosenColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var colorPicker: ColorPicker = {
        let colorPicker = ColorPicker(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(100), height: CGFloat(100)))
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        return colorPicker
    }()

    override func viewDidLoad() {
        view.addSubview(colorPicker)
        view.addSubview(chosenColorView)
        view.addSubview(hexLabel)
        
        setupSubviews()
    }
    
    func setupSubviews() {
        
        NSLayoutConstraint.activate([
            chosenColorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(10)),
            chosenColorView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            chosenColorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            chosenColorView.heightAnchor.constraint(equalToConstant: CGFloat(100)),
            
            colorPicker.topAnchor.constraint(equalTo: chosenColorView.bottomAnchor, constant: CGFloat(10)),
            colorPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            colorPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            colorPicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),
            
            hexLabel.leadingAnchor.constraint(equalTo: chosenColorView.trailingAnchor),
            hexLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            hexLabel.centerYAnchor.constraint(equalTo: chosenColorView.centerYAnchor),
            hexLabel.topAnchor.constraint(equalTo: chosenColorView.topAnchor),
            hexLabel.bottomAnchor.constraint(equalTo: chosenColorView.bottomAnchor),
            
        ])
        
        view.backgroundColor = UIColor(hue: CGFloat(0), saturation: CGFloat(0), brightness: CGFloat(1), alpha: CGFloat(0.1))
        
        colorPicker.intermediateDelegate = self
    }
}

@IBDesignable
class ColorPicker : UIView {
    
    weak internal var delegate: ColorPickerDelegate?
    weak internal var intermediateDelegate: ColorPickerIntermediateDelegate?
    let saturationExponentTop:Float = 2.0
    let saturationExponentBottom:Float = 1.3
    
    @IBInspectable var elementSize: CGFloat = 5.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func initialize() {
        self.clipsToBounds = true
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.touchedColor(gestureRecognizer:)))
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
        self.addGestureRecognizer(touchGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for y : CGFloat in stride(from: 0.0 ,to: rect.height, by: elementSize) {
            var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
            saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
            let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
            for x : CGFloat in stride(from: 0.0 ,to: rect.width, by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
            }
        }
    }
    
    func getColorAtPoint(point:CGPoint) -> UIColor {
        let roundedPoint = CGPoint(x:elementSize * CGFloat(Int(point.x / elementSize)),
                                   y:elementSize * CGFloat(Int(point.y / elementSize)))
        var saturation = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / self.bounds.height
            : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        saturation = CGFloat(powf(Float(saturation), roundedPoint.y < self.bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
        let brightness = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        let hue = roundedPoint.x / self.bounds.width
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    func getPointForColor(color:UIColor) -> CGPoint {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil);
        
        var yPos:CGFloat = 0
        let halfHeight = (self.bounds.height / 2)
        if (brightness >= 0.99) {
            let percentageY = powf(Float(saturation), 1.0 / saturationExponentTop)
            yPos = CGFloat(percentageY) * halfHeight
        } else {
            //use brightness to get Y
            yPos = halfHeight + halfHeight * (1.0 - brightness)
        }
        let xPos = hue * self.bounds.width
        return CGPoint(x: xPos, y: yPos)
    }
    
    @objc func touchedColor(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended) {
            let point = gestureRecognizer.location(in: self)
            let color = getColorAtPoint(point: point)
            DDLogInfo("Color touched \(color) \(point)")
            self.delegate?.ColorColorPickerTouched(sender: self, color: color, point: point, state:gestureRecognizer.state)
        }
        if (gestureRecognizer.state == UIGestureRecognizer.State.changed) {
            let point = gestureRecognizer.location(in: self)
            let color = getColorAtPoint(point: point)
            DDLogInfo("Color touche begin \(color) \(point)")
            self.intermediateDelegate?.ColorColorPickerTouchBegin(sender: self, color: color, point: point, state:gestureRecognizer.state)
        }
    }
}
