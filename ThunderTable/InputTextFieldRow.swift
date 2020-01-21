//
//  InputTextFieldRow.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 15/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit

public typealias ValidCharacterHandler = (_ string: String) -> Bool

open class InputTextFieldRow: InputTableRow {
    
    public typealias CellClass = InputTextFieldViewCell

    open var placeholder: String?
    
    open var keyboardType: UIKeyboardType
    
    open var returnKeyType: UIReturnKeyType
	
	open var allowCharacterHandler: ValidCharacterHandler?

    open var isSecure: Bool = false
    
    open var autocorrectionType: UITextAutocorrectionType = .default
    
    open var autocapitalizationType: UITextAutocapitalizationType = .none
    
    public init(title: String?, placeholder: String?, id: String, required: Bool, keyboardType: UIKeyboardType = .default, returnKeyType: UIReturnKeyType = .default) {
        
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        
        super.init(id: id, required: required)
        
        self.title = title
        self.placeholder = placeholder
        self.id = id
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        guard let textCell = cell as? InputTextFieldViewCell else { return }
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
            
        textCell.textField.placeholder = placeholder
        textCell.textField.keyboardType = keyboardType
        textCell.textField.returnKeyType = returnKeyType
        textCell.textField.isSecureTextEntry = isSecure
        textCell.textField.autocorrectionType = autocorrectionType
        textCell.textField.autocapitalizationType = autocapitalizationType
        
        textCell.textField.text = value as? String
        textCell.textField.delegate = self
        
        updateTargetsAndSelectors(for: textCell.textField)
        
        if let stringValue = value as? String {
            textCell.textField.text = stringValue
        } else if let value = value, value as? NSNull == nil {
            textCell.textField.text = String(describing: value)
		} else {
			textCell.textField.text = nil
		}
		
        textCell.cellTextLabel?.isHidden = title == nil
    }
}

extension InputTextFieldRow: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		// If our allow handler says no, then ignore the change that was made
		if let allowHandler = allowCharacterHandler, !allowHandler(string) {
			return false
		}
        
        var editedString = textField.text as NSString?
        editedString = editedString?.replacingCharacters(in: range, with: string) as NSString?
        
        set(value: editedString, sender: textField)
        
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        _nextHandler?(textField)
        return false
    }
}
