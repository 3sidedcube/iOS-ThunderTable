//
//  InputInlineDatePickerViewCell.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 16/09/2020.
//  Copyright © 2020 3SidedCube. All rights reserved.
//

import UIKit

/// An `InputDatePickerViewCell` subclass with an image, title label, and a date picker aligned horizontally
///
/// This cell subclass allows the user to pick a date using a `UIDatePicker` embedded "inline"
/// as one of the cell's subviews. This allows for use of
open class InputInlineDatePickerViewCell: InputDatePickerViewCell {
			
    override open func becomeFirstResponder() -> Bool {
        return datePicker?.becomeFirstResponder() ?? false
    }
    
    override open func resignFirstResponder() -> Bool {
        return datePicker?.resignFirstResponder() ?? false
    }
}
