//
//  InputTextFieldViewCell.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 15/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit

/// A `TableViewCell` subclass with an image, title label, and a text field aligned horizontally
///
/// This cell subclass allows the user to pick a date using a `UIDatePicker`set as the text field's
/// `inputView`, meaning it shows in-place of the default iOS keyboard
open class InputDatePickerViewCell: TableViewCell {
    
    public var inputTextField: UITextField? {
        return textField
    }
    
    /// The text field allowing the user to enter a date
    @IBOutlet weak public var textField: UITextField?
    
    /// The date picker the user uses to pick the date
    @IBOutlet public var datePicker: UIDatePicker? = UIDatePicker()
    
    /// The date formatter used to format the date displayed in `textField`
	public var dateFormatter: DateFormatter? = DateFormatter()
		
    override open func becomeFirstResponder() -> Bool {
        return textField?.becomeFirstResponder() ?? false
    }
    
    override open func resignFirstResponder() -> Bool {
        return textField?.resignFirstResponder() ?? false
    }
	
	open override func awakeFromNib() {
		
		super.awakeFromNib()
		
		let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 44))
		doneToolbar.isTranslucent = true
		doneToolbar.barTintColor = .white
		doneToolbar.tintColor = ThemeManager.shared.theme.mainColor
		
		doneToolbar.items = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone(sender:)))
		]
		
		textField?.inputView = datePicker
		textField?.inputAccessoryView = doneToolbar
	}
	
	@objc private func handleDone(sender: UIBarButtonItem) {
		textField?.resignFirstResponder()
	}
    
    @objc public func updateInputTextFieldText(sender: UIDatePicker) {
        textField?.text = dateFormatter?.string(from: sender.date)
    }
}
