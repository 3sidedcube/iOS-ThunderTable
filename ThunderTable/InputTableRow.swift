//
//  InputTableRow.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 15/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import Foundation

/// This protocol can be used to represent a `Row` in a `TableViewController` which can receive user input
public protocol InputRow: Row {
    
    /// The unique identifier of the input, this is used to store the value for later use
    var id: String { get }
    
    /// The current value of the input row
    var value: Any? { get set }
    
    /// Whether or not the value is required
    var required: Bool { get }
    
    /// Sets the value on the row, with an optional sender
    ///
    /// - parameter value:  The value which self.value should be updated to
    /// - parameter sender: The control which changed the value
    func set(value: Any?, sender: UIControl)
}

public typealias InputCallback = (_ sender: UIControl) -> (Void)

public struct Callback {
    
    var identifier: String
    
    var callback: InputCallback
    
    init(identifier: String, callback: @escaping InputCallback) {
        
        self.identifier = identifier
        self.callback = callback
    }
}

open class InputTableRow: InputRow {
    
    open var id: String
    
    open var value: Any?
    
    open var required: Bool
    
    open var title: String?
    
    open var subtitle: String?
    
    open var image: UIImage?
    
    open var prototypeIdentifier: String? {
        return nil
    }
    
    open var selectionHandler: SelectionHandler?
    
    open var cellClass: AnyClass? {
        return TableViewCell.self
    }
    
    open var estimatedHeight: CGFloat? {
        return nil
    }
    
    open var padding: CGFloat? {
        return nil
    }
    
    open var remainSelected: Bool {
        return false
    }
    
    open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        
    }
    
    public func set(value: Any?, sender: UIControl) {
        
        let events = UIControlEvents.valueChanged
        
        callbacks(for: events).forEach { (callback) in
            callback.callback(sender)
        }
    }
    
    init(id: String, required: Bool = false) {
        
        self.id = id
        self.required = required
    }
    
    //MARK: - Targets and Selectors
    
    private var callbacks: [UInt : [Callback]] = [:]
    
    public func add(callback: Callback, for controlEvents: UIControlEvents) {
        for i in 0...19 {
            
            let controlEvent = UIControlEvents(rawValue: UInt(i))
            if controlEvents.contains(controlEvent) {
                
                if var eventCallbacks = callbacks[controlEvent.rawValue] {
                    eventCallbacks.append(callback)
                } else {
                    callbacks[controlEvent.rawValue] = [callback]
                }
            }
        }
    }

    public func remove(callback: Callback, for controlEvents: UIControlEvents) {
        
        // If provide a target and a selector, only remove events for that target and selector
        for i in 0...19 {
            
            let controlEvent = UIControlEvents(rawValue: UInt(i))
            
            if controlEvents.contains(controlEvent) {
                
                if var eventCallbacks = callbacks[controlEvent.rawValue] {
                    
                    if let index = eventCallbacks.index(where: {
                        return $0.identifier == callback.identifier
                    } ) {
                        eventCallbacks.remove(at: index)
                    }
                }
            }
        }
    }
    
    public func callbacks(for controlEvents: UIControlEvents) -> [Callback] {
        
        var returnCallbacks: [Callback] = []
        
        for i in 0...19 {
            
            let controlEvent = UIControlEvents(rawValue: UInt(i))
            
            if let eventCallbacks = callbacks[UInt(i)], controlEvents.contains(controlEvent) {
                
                returnCallbacks.append(contentsOf: eventCallbacks)
            }
        }
        
        return returnCallbacks
    }
    
    /// Helper function to update the targets/selectors of the control determining self.value
    ///
    /// - parameter control: The control to set the target and actions on
    public func updateTargetsAndSelectors(for control: UIControl) {
        
        control.removeTarget(nil, action: nil, for: .allEvents)
        
        
        control.addTarget(self, action: #selector(touchDown(control:)), for: .touchDown)
        control.addTarget(self, action: #selector(touchDownRepeat(control:)), for: .touchDownRepeat)
        control.addTarget(self, action: #selector(touchDragInside(control:)), for: .touchDragInside)
        control.addTarget(self, action: #selector(touchDragOutside(control:)), for: .touchDragOutside)
        control.addTarget(self, action: #selector(touchDragEnter(control:)), for: .touchDragEnter)
        control.addTarget(self, action: #selector(touchDragExit(control:)), for: .touchDragExit)
        control.addTarget(self, action: #selector(touchUpInside(control:)), for: .touchUpInside)
        control.addTarget(self, action: #selector(touchUpOutside(control:)), for: .touchUpOutside)
        control.addTarget(self, action: #selector(touchCancel(control:)), for: .touchCancel)
        control.addTarget(self, action: #selector(valueChanged(control:)), for: .valueChanged)
        control.addTarget(self, action: #selector(primaryActionTriggered(control:)), for: .primaryActionTriggered)
        control.addTarget(self, action: #selector(editingDidBegin(control:)), for: .editingDidBegin)
        control.addTarget(self, action: #selector(editingChanged(control:)), for: .editingChanged)
        control.addTarget(self, action: #selector(editingDidEnd(control:)), for: .editingDidEnd)
        control.addTarget(self, action: #selector(editingDidEndOnExit(control:)), for: .editingDidEndOnExit)
    }
    
    // This is messy, but required unfortunately
    @objc private func touchDown(control: UIControl) {
        
        callbacks(for: .touchDown).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func touchDownRepeat(control: UIControl) {
        
        callbacks(for: .touchDownRepeat).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func touchDragInside(control: UIControl) {
        
        callbacks(for: .touchDragInside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func touchDragOutside(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func touchDragEnter(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func touchDragExit(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func touchUpInside(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func touchUpOutside(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func touchCancel(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func valueChanged(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func primaryActionTriggered(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func editingDidBegin(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func editingChanged(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func editingDidEnd(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
    
    @objc private func editingDidEndOnExit(control: UIControl) {
        
        callbacks(for: .touchDragOutside).forEach { (callback) in
            callback.callback(control)
        }
    }
}