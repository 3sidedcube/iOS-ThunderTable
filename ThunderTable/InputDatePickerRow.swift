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
	
	/// The date picker mode for the row
	open var mode: UIDatePicker.Mode = .dateAndTime
	
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
        get {
            return InputDatePickerViewCell.self
        }
        set {
            
        }
	}
	
	open override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		guard let datePickerCell = cell as? InputDatePickerViewCell else { return }
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		// Targets and selectors
		updateTargetsAndSelectors(for: datePickerCell.textField)
		datePickerCell.dateFormatter = dateFormatter
		datePickerCell.textField.delegate = self
		datePickerCell.datePicker.addTarget(self, action: #selector(handleChange(sender:)), for: .valueChanged)
		datePickerCell.datePicker.addTarget(datePickerCell, action: #selector(InputDatePickerViewCell.updateLabel(sender:)), for: .valueChanged)
		
		// Setting up date picker
		datePickerCell.datePicker.minimumDate = minimumDate
		datePickerCell.datePicker.maximumDate = maximumDate
		datePickerCell.datePicker.datePickerMode = mode
		
		if let dateValue = value as? Date {
			datePickerCell.textField.text = dateFormatter.string(from: dateValue)
		} else {
			datePickerCell.textField.text = nil
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
