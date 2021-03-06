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
    func colorPickerTouched(_ sender: ColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State)
}

@objc internal protocol ColorPickerIntermediateDelegate {
    func colorPickerTouchBegin(sender: ColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State)
}

final class ColorPickerController: UIViewController, ColorPickerIntermediateDelegate {
    func colorPickerTouchBegin(sender: ColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        DDLogInfo("Color picker Controller touch began")
        chosenColorView.backgroundColor = color
        hexLabel.text = color.hexString

        updateColorCursorPosition(at: colorPicker.absolutePoint(from: point))
    }

    private func updateColorCursorPosition(at point: CGPoint) {
        colorCursor.frame = CGRect(x: point.x - colorCursor.frame.width/2, y: point.y - colorCursor.frame.height/2, width: colorCursor.frame.width, height: colorCursor.frame.height)
    }

    @objc func opacitySliderChange(sender: UISlider) {
        colorPicker.opacity = sender.value
        DDLogInfo("Opacity set to \(colorPicker.opacity)")
        colorPicker.draw(colorPicker.frame)
    }

    let hexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    let chosenColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let colorPicker: ColorPicker = {
        let colorPicker = ColorPicker(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(100), height: CGFloat(100)))
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        return colorPicker
    }()

    let opacityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Opacity"
        return label
    }()

    let opacitySlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        //        slider.textAlignment = .center;
        slider.value = 1
        return slider
    }()

    let colorCursor: PassThroughView = {
        var cursor = PassThroughView()
        return cursor
    }()

    override func viewDidLoad() {
        view.addSubview(colorPicker)
        view.addSubview(chosenColorView)
        view.addSubview(hexLabel)
        view.addSubview(opacityLabel)
        view.addSubview(opacitySlider)
        view.addSubview(colorCursor)

        setupSubviews()
    }

    func setupSubviews() {

        NSLayoutConstraint.activate([
            chosenColorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(10)),
            chosenColorView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5, constant: CGFloat(-10)),
            chosenColorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            chosenColorView.heightAnchor.constraint(equalToConstant: CGFloat(100)),

            hexLabel.topAnchor.constraint(equalTo: chosenColorView.bottomAnchor),
            hexLabel.widthAnchor.constraint(equalToConstant: CGFloat(20)),
            hexLabel.leadingAnchor.constraint(equalTo: chosenColorView.leadingAnchor),
            hexLabel.trailingAnchor.constraint(equalTo: chosenColorView.trailingAnchor),

            colorPicker.topAnchor.constraint(equalTo: chosenColorView.bottomAnchor, constant: CGFloat(30)),
            colorPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            colorPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(10)),
            colorPicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),

            opacityLabel.topAnchor.constraint(equalTo: chosenColorView.topAnchor),
            opacityLabel.bottomAnchor.constraint(equalTo: chosenColorView.bottomAnchor),
            opacityLabel.leadingAnchor.constraint(equalTo: chosenColorView.trailingAnchor, constant: CGFloat(10)),
            opacityLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10)),

            opacitySlider.bottomAnchor.constraint(equalTo: chosenColorView.bottomAnchor),
            opacitySlider.leadingAnchor.constraint(equalTo: chosenColorView.trailingAnchor, constant: CGFloat(10)),
            opacitySlider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-10))
        ])

        view.backgroundColor = UIColor(hue: CGFloat(0), saturation: CGFloat(0), brightness: CGFloat(1), alpha: CGFloat(0.1))

        colorPicker.intermediateDelegate = self

        view.backgroundColor = .white

        opacitySlider.addTarget(self, action: #selector(opacitySliderChange), for: .valueChanged)

        let colorCursorSize = CGFloat(30)
        colorCursor.frame = CGRect(x: view.center.x, y: view.center.y, width: colorCursorSize, height: colorCursorSize)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: colorCursorSize/2, y: colorCursorSize/2), radius: colorCursorSize/2, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 3.0
        colorCursor.layer.addSublayer(shapeLayer)
    }
}

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}

@IBDesignable
class ColorPicker: UIView {

    weak internal var delegate: ColorPickerDelegate?
    weak internal var intermediateDelegate: ColorPickerIntermediateDelegate?
    var saturationExponentTop: Float = 2.0
    let saturationExponentBottom: Float = 1.3
    var opacity: Float = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }

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
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context.fill(rect)

        for y: CGFloat in stride(from: 0.0, to: rect.height, by: elementSize) {
            var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
            saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
            let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
            for x: CGFloat in stride(from: 0.0, to: rect.width, by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: CGFloat(opacity))
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: elementSize, height: elementSize))
            }
        }
    }

    func colorAtPoint(point: CGPoint) -> UIColor {
        let roundedPoint = CGPoint(x: elementSize * CGFloat(Int(point.x / elementSize)),
                                   y: elementSize * CGFloat(Int(point.y / elementSize)))
        return UIColor(hue: hueAtPoint(roundedPoint), saturation: saturationAtPoint(roundedPoint), brightness: brightnessAtPoint(roundedPoint), alpha: CGFloat(opacity))
    }

    private func saturationAtPoint(_ roundedPoint: CGPoint) -> CGFloat {
        let saturation = roundedPoint.y < self.bounds.height / 2.0
            ? CGFloat(2 * roundedPoint.y) / self.bounds.height
            : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        return CGFloat(powf(Float(saturation), roundedPoint.y < self.bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
    }

    private func brightnessAtPoint(_ roundedPoint: CGPoint) -> CGFloat {
        return roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
    }

    private func hueAtPoint(_ roundedPoint: CGPoint) -> CGFloat {
        return roundedPoint.x / self.bounds.width
    }

    func pointForColor(color: UIColor) -> CGPoint {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        var yPos: CGFloat = 0
        let halfHeight = (self.bounds.height / 2)
        if brightness >= 0.99 {
            let percentageY = powf(Float(saturation), 1.0 / saturationExponentTop)
            yPos = CGFloat(percentageY) * halfHeight
        } else {
            yPos = halfHeight + halfHeight * (1.0 - brightness)
        }
        let xPos = hue * self.bounds.width
        return CGPoint(x: xPos, y: yPos)
    }

    @objc func touchedColor(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            let point = gestureRecognizer.location(in: self)
            let color = colorAtPoint(point: point)
            DDLogInfo("Color touched \(color) \(point)")
            self.delegate?.colorPickerTouched(self, color: color, point: point, state: gestureRecognizer.state)
        }
        if gestureRecognizer.state == UIGestureRecognizer.State.changed {
            let point = gestureRecognizer.location(in: self)
            let color = colorAtPoint(point: point)
            DDLogInfo("Color touche begin \(color) \(point)")
            self.intermediateDelegate?.colorPickerTouchBegin(sender: self, color: color, point: point, state: gestureRecognizer.state)
        }
    }

    func absolutePoint(from point: CGPoint) -> CGPoint {
        return CGPoint(x: self.frame.minX + point.x, y: self.frame.minY + point.y)
    }
}
