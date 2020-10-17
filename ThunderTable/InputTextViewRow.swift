//
//  InputTextFieldRow.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 15/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit

open class InputTextViewRow: InputTableRow {

    open var placeholder: String?
    
    open var keyboardType: UIKeyboardType
    
    open var returnKeyType: UIReturnKeyType
    
    open var autocorrectionType: UITextAutocorrectionType = .default
    
    open var autocapitalizationType: UITextAutocapitalizationType = .none
    
    open var textViewHeight: CGFloat = 60
    
    open var isSecure: Bool = false
    
    override open var cellClass: UITableViewCell.Type? {
        return InputTextViewCell.self
    }
    
    public init(title: String?, placeholder: String?, id: String, required: Bool, keyboardType: UIKeyboardType = .default, returnKeyType: UIReturnKeyType = .default) {
        
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        
        super.init(id: id, required: required)
        
        self.title = title
        self.placeholder = placeholder
        self.id = id
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        guard let textCell = cell as? InputTextViewCell else { return }
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        textCell.cellTextLabel?.isHidden = title == nil
        
        textCell.textViewHeightConstraint.constant = textViewHeight
        textCell.textView.keyboardType = keyboardType
        textCell.textView.returnKeyType = returnKeyType
        textCell.textView.isSecureTextEntry = isSecure
        textCell.textView.autocorrectionType = autocorrectionType
        textCell.textView.autocapitalizationType = autocapitalizationType
        
        textCell.textView.delegate = self
        
        if let stringValue = value as? String {
            
            textCell.textView.text = stringValue
            textCell.textView.textColor = ThemeManager.shared.theme.cellTitleColor
            
        } else if let value = value, value as? NSNull == nil {
            
            textCell.textView.textColor = ThemeManager.shared.theme.cellTitleColor
            textCell.textView.text = String(describing: value)
            
        } else {
            
            textCell.textView.text = placeholder
            if #available(iOS 13.0, *) {
                textCell.textView.textColor = .placeholderText
            } else {
                textCell.textView.textColor = .lightGray
            }
        }
    }
}

extension InputTextViewRow: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        
        if let stringValue = value as? String {
            
            textView.text = stringValue
            textView.textColor = ThemeManager.shared.theme.cellTitleColor
            
        } else if let value = value, value as? NSNull == nil {
            
            textView.text = String(describing: value)
            textView.textColor = ThemeManager.shared.theme.cellTitleColor
            
        } else {
            
            textView.text = nil
            textView.textColor = ThemeManager.shared.theme.cellTitleColor
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = placeholder
            if #available(iOS 13.0, *) {
                textView.textColor = .placeholderText
            } else {
                textView.textColor = .lightGray
            }
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        set(value: textView.text, sender: nil)
    }
}
