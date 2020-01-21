//
//  InputSwitchRow.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 16/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit

/// An input row which provides a title, subtitle, and `UISwitch` in it's UI
open class InputSwitchRow: InputTableRow {
	
	public var isEnabled = true
	
	public var isUserInteractionEnabled = true
    
    /// Defines whether to group the label and switch as a single accessibility element
    /// - Note: Defaults to true!
    public var accessibilityGroupLabelsAndSwitch: Bool = true
    
    public typealias CellClass = InputSwitchViewCell
    
    public override var cellClass: UITableViewCell.Type? {
        get {
            return InputSwitchViewCell.self
        }
        set { }
    }
    
    public init(title: String?, subtitle: String?, id: String, image: UIImage? = nil) {
        
        super.init(id: id, required: false)
        
        isAccessibilityElement = true
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        guard let switchCell = cell as? InputSwitchViewCell else { return }
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        updateTargetsAndSelectors(for: switchCell.switch)
        switchCell.switch.addTarget(self, action: #selector(handleChange(sender:)), for: .valueChanged)
        
        if let boolValue = value as? Bool {
            switchCell.switch.isOn = boolValue
        } else {
            switchCell.switch.isOn = false
        }
        
        switchCell.accessibilityGroupLabelsAndSwitch = accessibilityGroupLabelsAndSwitch
		
		switchCell.switch.isEnabled = isEnabled
		switchCell.switch.isUserInteractionEnabled = isUserInteractionEnabled
        
        switchCell.cellTextLabel?.isHidden = title == nil
        switchCell.cellDetailLabel?.isHidden = subtitle == nil
    }
    
    @objc func handleChange(sender: UISwitch) {
        set(value: sender.isOn, sender: sender)
    }
}
