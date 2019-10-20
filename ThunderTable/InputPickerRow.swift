//
//  InputPickerRow.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 15/02/2018.
//  Copyright © 2018 3SidedCube. All rights reserved.
//

import UIKit

/// A protocol which can be used to represent a component in a `UIPickerView`
public protocol PickerComponentDisplayable {
    
    /// The items to be displayed in the component
    var items: [PickerRowDisplayable] { get }
}

/// A helper class for ease of use of `PickerComponentDisplayable`
open class PickerComponent: PickerComponentDisplayable {
    
    /// The items to be displayed in the component
    open var items: [PickerRowDisplayable]
    
    public init(items: [PickerRowDisplayable]) {
        self.items = items
    }
}

/// A protocol which can be used to provide rows to a `UIPickerView` component
public protocol PickerRowDisplayable {
    
    /// The value that this row represents, doesn't have to be the same as title
    var value: AnyHashable { get }
    
    /// The title to display on this row
    var rowTitle: String { get }
    
    /// The attributed title to display on this row (Optional)
    var attributedTitle: NSAttributedString? { get }
}

public extension PickerRowDisplayable {
    
    var attributedTitle: NSAttributedString? { get { return nil } }
}

/// A helper class for ease of use of `PickerRowDisplayable`
open class PickerRow: PickerRowDisplayable {
    
    /// The value that this row represents, doesn't have to be the same as title
    open var value: AnyHashable
    
    /// The title to display on this row
    open var rowTitle: String
    
    /// Creates a new instance with a title and value
    ///
    /// - Parameters:
    ///   - title: The title to display in the `UIPickerView`
    ///   - value: The value that the row represents
    public init(title: String, value: AnyHashable) {
        self.rowTitle = title
        self.value = value
    }
}

/// A row which displays a picker in the keyboard for the user
/// to select from a set of defined options
open class InputPickerRow: InputTableRow {
    
    /// The components to display in the picker
    open var components: [PickerComponentDisplayable]
    
    /// A closure to format the value of the row
    open var formatter: ((_ value: [AnyHashable]) -> String)
    
    /// Creates a new row from provided properties
    ///
    /// - Parameters:
    ///   - title: The title of the row
    ///   - mode: The mode of the date picker
    ///   - id: The unique id for this row
    ///   - required: Whether the value is required
    public init(title: String?, components: [PickerComponentDisplayable], formatter: @escaping ((_ value: [AnyHashable]) -> String), id: String, required: Bool) {
        
        self.formatter = formatter
        self.components = components
        super.init(id: id, required: required)
        self.title = title
    }
    
    open override var cellClass: UITableViewCell.Type? {
        return InputPickerViewCell.self
    }
    
    private var cellTextField: UITextField?
    
    open override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        guard let pickerCell = cell as? InputPickerViewCell else { return }
        
        // Targets and selectors
        updateTargetsAndSelectors(for: pickerCell.textField)
        pickerCell.textField.delegate = self
        pickerCell.picker.delegate = self
        pickerCell.picker.dataSource = self
        
        cellTextField = pickerCell.textField
        
        guard let values = value as? [AnyHashable] else { return }
        
        for (i, component) in components.enumerated() {
            
            guard i < values.count else { return }
            let rowValue = values[i]
            
            guard let selectedIndex = component.items.index(where: {
                $0.value == rowValue
            }) else { return }
            
            pickerCell.picker.selectRow(selectedIndex, inComponent: i, animated: false)
        }
        
        // Setting up the picker
        
        if let arrayValue = value as? [AnyHashable] {
            pickerCell.textField.text = formatter(arrayValue)
        } else {
            let arrayValue = components.compactMap({ $0.items.first?.value })
            pickerCell.textField.text = formatter(arrayValue)
        }
    }
}

extension InputPickerRow: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        nextHandler?(textField)
        return false
    }
}

extension InputPickerRow: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return components[component].items[row].rowTitle
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return components[component].items[row].attributedTitle
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var values: [AnyHashable] = []
        
        for (i, component) in components.enumerated() {
            let selectedIndex = pickerView.selectedRow(inComponent: i)
            guard selectedIndex < component.items.count else { continue } 
            let value = component.items[selectedIndex].value
            values.append(value)
        }
        
        self.set(value: values, sender: nil)
        cellTextField?.text = formatter(values)
    }
}

extension InputPickerRow: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return components.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return components[component].items.count
    }
}
