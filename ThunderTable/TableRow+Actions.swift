//
//  TableRow+Actions.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 15/02/2018.
//  Copyright © 2018 3SidedCube. All rights reserved.
//

import UIKit

/// The action style for a contextual action.
///
/// - `default`: Equivalent to normal on iOS >= 11.
/// - destructive: A destructive action, i.e. removes the row.
/// - normal: Any other action.
public enum RowActionableStyle {
    case `default`
    case destructive
    case normal
    
    @available(iOS 11.0, *)
    var _UIContextualActionStyle: UIContextualAction.Style {
        switch self {
        case .destructive:
            return .destructive
        default:
            return .normal
        }
    }
    
    var _UITableViewRowActionStyle: UITableViewRowAction.Style {
        switch self {
        case .destructive:
            return .destructive
        case .default:
            return .default
        case .normal:
            return .normal
        }
    }
}

/// A closure called when a `RowActionable` is triggered by the user.
/// Call the completionHandler (iOS 11 and above) to reset the context to its normal state (e.g. when swiping, resets to unswiped state).
/// Pass YES to the completionHandler if the action was actually performed, to show a visual indication of the successful completion (iOS 11 and above only).
/// `view` will only be non-nil on iOS 11 and above.
public typealias RowActionableHandler = (_ action: RowActionable, _ view: UIView?, _ callback: ((Bool) -> Void)?, _ row: AnyRow, _ indexPath: IndexPath, _ tableView: UITableView) -> Void

/// A protocol which can be conformed to to provide an action upon swiping a `UITableViewCell`.
/// In an editable table, performing a horizontal swipe in a row reveals a button to delete the row by default. This protocol lets you define one or more custom actions to display for a given row in your table. Each instance of this protocol represents a single action to perform and includes the text, formatting information, and behavior for the corresponding button.
public protocol RowActionable {
    
    /// The style of the action.
    var style: RowActionableStyle { get }
    
    /// The title to be displayed on the action.
    var title: String? { get }
    
    /// A handler called when the action is actioned.
    var handler: RowActionableHandler { get }
    
    /// Background color of the button.
    /// Default background color is dependent on style.
    var backgroundColor: UIColor? { get }
    
    /// The visual effect to apply to the action's button (iOS 10).
    var backgroundEffect: UIVisualEffect? { get }
    
    /// The image to be displayed on the action (iOS 11 >).
    var image: UIImage? { get }
}

/// A base class which can be subclassed providing a template for the `RowActionable` protocol.
open class RowAction: RowActionable {
    
    /// The background color of the action's button.
    open var backgroundColor: UIColor?
    
    /// The visual effect to apply to the action's button.
    open var backgroundEffect: UIVisualEffect?
    
    /// The style of the action.
    open var style: RowActionableStyle
    
    /// The title to be displayed on the action.
    open var title: String?
    
    /// The image to be displayed on the action (iOS 11 >).
    open var image: UIImage?
    
    /// A closure called when the action is triggered.
    open var handler: RowActionableHandler
    
    /// Creates a new action with the provided parameters.
    ///
    /// - Parameters:
    ///   - style: The style of the action.
    ///   - title: The title to be displayed on the action.
    ///   - handler: A closure called when the action is triggered.
    public init(style: RowActionableStyle, title: String?, handler: @escaping RowActionableHandler) {
        
        self.style = style
        self.title = title
        self.handler = handler
    }
}

extension RowActionable {
    
    @available(iOS 11.0, *)
    /// Creates a `UIContextualAction` to be used in a `UISwipeActionsConfiguration` with the provided handler.
    ///
    /// - Parameter handler: The handler to be called.
    /// - Returns: A `UIContextualAction`.
    func contextualAction(with handler: @escaping UIContextualAction.Handler) -> UIContextualAction {
        
        let action = UIContextualAction(style: style._UIContextualActionStyle, title: title, handler: handler)
        // Only set this if non-nil otherwise we end up with no default colouring and a transparent background to the button
        if backgroundColor != nil {
            action.backgroundColor = backgroundColor
        }
        action.image = image
        return action
    }
    
    /// Creates a `UITableViewRowAction` to be used in the delegate method of `UITableViewController` with the provided handler.
    ///
    /// - Parameter handler: The handler to be called.
    /// - Returns: A `UIContextualAction`.
    func rowAction(with handler: @escaping (UITableViewRowAction, IndexPath) -> Void) -> UITableViewRowAction {
        
        let rowAction = UITableViewRowAction(style: style._UITableViewRowActionStyle, title: title, handler: handler)
        // Only set this if non-nil otherwise we end up with no default colouring and a transparent background to the button
        if backgroundColor != nil {
            rowAction.backgroundColor = backgroundColor
        }
        rowAction.backgroundEffect = backgroundEffect
        return rowAction
    }
    
    var backgroundColor: UIColor? { get { return nil } }
    
    var backgroundEffect: UIVisualEffect? { get { return nil } }
    
    var image: UIImage? { get { return nil } }
}

/// A protocol which can be conformed to to provide swipe action information for a row.
public protocol SwipeActionsConfigurable {
    
    /// The actions to be shown on the row.
    var actions: [RowActionable] { get }
    
    /// Whether a full swipe should perform the first action (iOS 11 and above only).
    var performsFirstActionWithFullSwipe: Bool { get set } // default YES, set to NO to prevent a full swipe from performing the first action
}


extension SwipeActionsConfigurable {
    
    /// Creates a `UISwipeActionsConfiguration` from the `SwipeActionsConfigurable` to be used in the delegate methods of `UITableView`.
    ///
    /// - Parameters:
    ///   - row: The row that this configurable is for.
    ///   - indexPath: The indexPath that this configurable was triggered at.
    ///   - tableView: The table view the configuration will be used in.
    /// - Returns: A `UISwipeActionsConfiguration` to be used in the table view.
    @available(iOS 11.0, *)
    func configurationFor(row: AnyRow, at indexPath: IndexPath, in tableView: UITableView) -> UISwipeActionsConfiguration {
        
        let contextualActions = actions.map { (actionable) -> UIContextualAction in
            let contextualAction = actionable.contextualAction(with: { (action, view, handler) in
                actionable.handler(actionable, view, handler, row, indexPath, tableView)
            })
            return contextualAction
        }
        
        let configuration = UISwipeActionsConfiguration(actions: contextualActions)
        configuration.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
        return configuration
    }
    
    func rowActionsFor(row: AnyRow, in tableView: UITableView) -> [UITableViewRowAction] {
        
        let rowActions = actions.map { (actionable) -> UITableViewRowAction in
            
            let rowAction = actionable.rowAction(with: { (action, indexPath) in
                actionable.handler(actionable, nil, nil, row, indexPath, tableView)
            })
            return rowAction
        }
        
        return rowActions
    }
}

/// A base class which can be subclassed providing a template for the `SwipeActionsConfigurable` protocol.
open class SwipeActionsConfiguration: SwipeActionsConfigurable {
    
    open var performsFirstActionWithFullSwipe: Bool = true
    
    open var actions: [RowActionable]
    
    public init(actions: [RowActionable]) {
        self.actions = actions
    }
}
