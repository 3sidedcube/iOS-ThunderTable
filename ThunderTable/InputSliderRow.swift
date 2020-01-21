//
//  InputSliderRow.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 16/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit

/// A row which displays a `UISlider` and label displaying it's value
///
/// - Important: If you use the valueChangeHandler on this row, and want to use the
/// sender part of that closure, make sure to use `correctedValue` rather than `value`
/// due to the custom implementation of UISlider allowing for non-integer steps.
/// This means `sender.value !== value` in that closure!
open class InputSliderRow: InputTableRow {
    
    public typealias CellClass = InputSliderViewCell
    
    override open var cellClass: UITableViewCell.Type? {
        get {
            return InputSliderViewCell.self
        }
        set {
            
        }
    }
    
    // Defines whether to group the label and slider as a single accessibility element
    /// - Note: Defaults to true!
    public var accessibilityGroupLabelsAndSlider = true
    
    /// The minimum value that can be chosen by the slider
    open var minValue: Float
    
    /// The maximum value that can be chosen by the slider
    open var maxValue: Float
    
    /// The interval at which the slider increments or decrements
	open var interval: Float
    
    /// A closure that will be called in order to format the accessibility value for the slider.
    /// This can be used to for example make the accessibility value read "2 miles" rather than simply "2"
    open var accessibilityValueFormatter: ((Float) -> String)?
    
    public init(title: String?, minValue: Float, maxValue: Float, id: String, required: Bool) {
        
        self.minValue = minValue
        self.maxValue = maxValue
		self.interval = 1.0
        
        super.init(id: id, required: required)
        
        self.title = title
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        guard let sliderCell = cell as? InputSliderViewCell else { return }
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        updateTargetsAndSelectors(for: sliderCell.slider)
        sliderCell.accessibilityValueFormatter = accessibilityValueFormatter
        sliderCell.slider.addTarget(self, action: #selector(handleChange(sender:)), for: .valueChanged)
        sliderCell.slider.addTarget(sliderCell, action: #selector(InputSliderViewCell.updateLabel(sender:)), for: .valueChanged)
        
        sliderCell.cellTextLabel?.isHidden = title == nil
        
        sliderCell.accessibilityGroupLabelsAndSlider = accessibilityGroupLabelsAndSlider
		
		sliderCell.slider.interval = interval
		sliderCell.slider.minimumValue = minValue
		sliderCell.slider.maximumValue = maxValue
		
		sliderCell.valueLabel.backgroundColor = ThemeManager.shared.theme.mainColor
		sliderCell.valueLabel.textColor = .white
		sliderCell.valueLabel.layer.cornerRadius = 5
		sliderCell.valueLabel.layer.masksToBounds = true
		
        if let doubleValue = value as? Float {
            sliderCell.slider.value = doubleValue
        } else {
            sliderCell.slider.value = minValue
        }
		
        if let value = value {
            sliderCell.valueLabel.text = "\(value)"
        } else {
            sliderCell.valueLabel.text = "\(minValue)"
        }
    }
    
    @objc func handleChange(sender: IntervalSlider) {
        set(value: sender.correctedValue, sender: sender)
    }
}
