//
//  InputDatePickerRow.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 03/01/2018.
//  Copyright © 2018 3SidedCube. All rights reserved.
//

import UIKit

/// A row which displays a date picker in the keyboard for the user
/// to select a date and formats the date nicely
open class InputDatePickerRow: InputTableRow {
    
    /// An direct map enum to `UIDatePickerStyle` so we can provide the `preferredDatePickerStyle` on iOS
    /// versions before iOS 13.4 without getting "Stored properties cannot be marked potentially unavailable with '@available'"
    /// compiler warning!
    public enum PickerStyle: Int {
        /// Automatically pick the best style available for the current platform & mode.
        case automatic = 0

        /// Use the wheels (UIPickerView) style. Editing occurs inline.
        case wheels = 1

        /// Use a compact style for the date picker. Editing occurs in an overlay.
        case compact = 2

        /// Use a style for the date picker that allows editing in place.
        case inline = 3
        
        @available (iOS 13.4, *)
        var datePickerStyle: UIDatePickerStyle {
            switch self {
            case .automatic:
                return .automatic
            case .compact:
                return .compact
            case .inline:
                if #available(iOS 14.0, *) {
                    return .inline
                } else {
                    return .automatic
                }
            case .wheels:
                return .wheels
            }
        }
        
        /// Returns the correct cell class for the style given the mode the date picker is set to
        /// - Parameter mode: The date picker mode the date picker is in
        /// - Returns: A table view cell class used to render the cell
        func cellClass(for mode: UIDatePicker.Mode) -> UITableViewCell.Type {
            
            // Even old versions of iOS can support `inline` no matter how much of a hot mess it is visually!
            if self == .inline {
                // Return new class
                return InputInlineDatePickerViewCell.self
            }
            
            // New `inline` and `compact` date pickers are only available on iOS 14
            guard #available(iOS 14, *) else {
                return InputDatePickerViewCell.self
            }
            
            switch mode {
            case .countDownTimer:
                // countdown timer doesn't have an `inline` or `compact` representation, so we
                // keep the traditional `wheels` cell for this case
                return InputDatePickerViewCell.self
            default:
                switch self {
                // Automatic, Compact and Inline should all use the inline style cell
                case .automatic, .compact, .inline:
                    return InputInlineDatePickerViewCell.self
                    // All others (.wheels) should use the original date picker cell
                default:
                    return InputDatePickerViewCell.self
                }
            }
        }
    }
	
	/// The date picker mode for the row
	open var mode: UIDatePicker.Mode = .dateAndTime
    
    /// The preferred date picker style for the row, this will only have an effect on iOS > 13.4
    open var preferredDatePickerStyle: PickerStyle = .automatic
	
	/// The minimum date allowed by the row
	open var minimumDate: Date?
	
	/// The maximum date allowed by the row
	open var maximumDate: Date?
	
	/// The formatter to style the date string
	open var dateFormatter: DateFormatter = DateFormatter()
	
	/// Creates a new row from provided properties
	///
	/// - Parameters:
	///   - title: The title of the row
	///   - mode: The mode of the date picker
	///   - id: The unique id for this row
	///   - required: Whether the value is required
	public init(title: String?, mode: UIDatePicker.Mode = .dateAndTime, id: String, required: Bool) {
		
		self.mode = mode
		
		super.init(id: id, required: required)

		self.title = title
		
		switch mode {
		case .date:
			dateFormatter.dateStyle = .long
			dateFormatter.timeStyle = .none
			break
		case .time:
			dateFormatter.timeStyle = .short
			break
		case .dateAndTime:
			dateFormatter.timeStyle = .short
			dateFormatter.dateStyle = .medium
			break
		case .countDownTimer:
			dateFormatter.dateFormat = "'Every' HH 'hours' mm 'minutes'"
			break
        @unknown default:
            fatalError("Unknown `UIDatePicker.Mode` encountered in `InputDatePickerRow` please add support for this new enum value")
        }
	}
	
	open override var cellClass: UITableViewCell.Type? {
        return preferredDatePickerStyle.cellClass(for: mode)
	}
	
	open override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
        guard let datePickerCell = cell as? InputDatePickerViewCell else { return }
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		// Targets and selectors
        // If we have a text field we use that for targets and selectors
        if let textField = datePickerCell.inputTextField {
            updateTargetsAndSelectors(for: textField)
            // Otherwise we add them to the date picker to make sure we still get callbacks!
        } else if let datePicker = datePickerCell.datePicker {
            updateTargetsAndSelectors(for: datePicker)
        }
        
		datePickerCell.dateFormatter = dateFormatter
		datePickerCell.inputTextField?.delegate = self
		datePickerCell.datePicker?.addTarget(self, action: #selector(handleChange(sender:)), for: .valueChanged)
        
		datePickerCell.datePicker?.addTarget(datePickerCell, action: #selector(datePickerCell.updateInputTextFieldText(sender:)), for: .valueChanged)
		
		// Setting up date picker
		datePickerCell.datePicker?.minimumDate = minimumDate
		datePickerCell.datePicker?.maximumDate = maximumDate
		datePickerCell.datePicker?.datePickerMode = mode
        
        if #available(iOS 13.4, *) {
            datePickerCell.datePicker?.preferredDatePickerStyle = preferredDatePickerStyle.datePickerStyle
        }
		
        if let textField = datePickerCell.inputTextField {
            
            if let dateValue = value as? Date {
                textField.text = dateFormatter.string(from: dateValue)
            } else {
                textField.text = nil
            }
            
        } else {
            
            datePickerCell.datePicker?.date = value as? Date ?? Date()
        }
	}
	
	@objc private func handleChange(sender: UIDatePicker) {
		set(value: sender.date, sender: sender)
	}
}

extension InputDatePickerRow: UITextFieldDelegate {
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()
		nextHandler?(textField)
		return false
	}
}
