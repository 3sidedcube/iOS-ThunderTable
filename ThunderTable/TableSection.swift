//
//  TableSection.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 14/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit

public typealias SelectionHandler = (_ row: Row, _ selected: Bool, _ indexPath: IndexPath, _ tableView: UITableView) -> (Void)

public typealias EditHandler = (_ row: Row, _ editingStyle: UITableViewCell.EditingStyle, _ indexPath: IndexPath, _ tableView: UITableView) -> (Void)

public protocol Section {
    
    var rows: [Row] { get }
    
    var header: String? { get }
    
    var footer: String? { get }
    
    var editHandler: EditHandler? { get }
    
    var selectionHandler: SelectionHandler? { get }
    
    var rowLeadingSwipeActionsConfiguration: SwipeActionsConfigurable? { get }
    
    var rowTrailingSwipeActionsConfiguration: SwipeActionsConfigurable? { get }
    
    /// A function which can be used to provide a `UIContextMenuConfiguration` for the row, at a given point
    /// - Parameters:
    ///   - point: The point within the table view that the context menu should be shown for
    ///   - indexPath: The index path the context menu will be displayed for
    ///   - tableView: The table view that the context menu will be shown within
    @available(iOS 13.0, *)
    func sectionContextMenuConfiguration(at point: CGPoint, for indexPath: IndexPath, in tableView: UITableView) -> UIContextMenuConfiguration?
    
    /// A function which can be used to provide the view for dismissing a given context menu
    /// - Parameters:
    ///   - configuration: The configuration that the dismissing menu is for
    ///   - indexPath: The index path the context menu is being displayed for
    ///   - tableView: The table view that the context menu is being dismissed in
    @available(iOS 13.0, *)
    func sectionPreviewForDismissingContextMenu(with configuration: UIContextMenuConfiguration, at indexPath: IndexPath, in tableView: UITableView) -> UITargetedPreview?
    
    /// A function which can be used to provide the view for highlighting a given context menu
    /// - Parameters:
    ///   - configuration: The configuration that the highlighting menu is for
    ///   - indexPath: The index path the context menu is being displayed for
    ///   - tableView: The table view that the context menu is being highlighted in
    @available(iOS 13.0, *)
    func sectionPreviewForHighlightingContextMenu(with configuration: UIContextMenuConfiguration, at indexPath: IndexPath, in tableView: UITableView) -> UITargetedPreview?
}

public extension Section {
    
    var rows: [Row] {
        return []
    }
    
    var header: String? {
        return nil
    }
    
    var footer: String? {
        return nil
    }
    
    var rowLeadingSwipeActionsConfiguration: SwipeActionsConfigurable? { return nil }
    
    var rowTrailingSwipeActionsConfiguration: SwipeActionsConfigurable? { return nil }
    
    @available(iOS 13.0, *)
    func sectionContextMenuConfiguration(at point: CGPoint, for indexPath: IndexPath, in tableView: UITableView) -> UIContextMenuConfiguration? { return nil }
    
    @available(iOS 13.0, *)
    func sectionPreviewForDismissingContextMenu(with configuration: UIContextMenuConfiguration, at indexPath: IndexPath, in tableView: UITableView) -> UITargetedPreview? { return nil }
    
    @available(iOS 13.0, *)
    func sectionPreviewForHighlightingContextMenu(with configuration: UIContextMenuConfiguration, at indexPath: IndexPath, in tableView: UITableView) -> UITargetedPreview? { return nil }
}

open class TableSection: Section {
    
    open var header: String?
    
    open var footer: String?
    
    open var rows: [Row]
    
    open var selectionHandler: SelectionHandler?
    
    open var editHandler: EditHandler?
    
    open var rowLeadingSwipeActionsConfiguration: SwipeActionsConfigurable?
    
    open var rowTrailingSwipeActionsConfiguration: SwipeActionsConfigurable?
    
    public init(rows: [Row], header: String? = nil, footer: String? = nil, selectionHandler: SelectionHandler? = nil) {
        
        self.rows = rows
        self.header = header
        self.footer = footer
        self.selectionHandler = selectionHandler
    }
    
    /// Returns an array of `TableSection` objects sorted by first letter of the row's title
    ///
    /// - Parameters:
    ///   - rows: The rows to sort into alphabetised sections
    ///   - selectionHandler: A selection handler to add to the sections
    /// - Returns: An array of `TableSection` objects
    public class func sortedSections(with rows: [Row], selectionHandler: SelectionHandler? = nil) -> [TableSection] {
        
        let sortedAlphabetically = self.alphabeticallySort(rows: rows)
        let sortedKeys = sortedAlphabetically.keys.sorted { (stringA, stringB) -> Bool in
            return stringB > stringA
        }
        
        return sortedKeys.compactMap({key -> TableSection? in
            guard let rows = sortedAlphabetically[key] else { return nil }
            return TableSection(rows: rows, header: key, footer: nil, selectionHandler: selectionHandler)
        })
    }
    
    private class func alphabeticallySort(rows: [Row]) -> [String : [Row]] {
        
        var sortedDict = [String : [Row]]()
        
        rows.forEach { (row) in
            
            var firstLetter = "?"
            if let rowTitle = row.title, !rowTitle.isEmpty {
                firstLetter = String(rowTitle.prefix(1)).uppercased()
            }
            var subItems = sortedDict[firstLetter] ?? []
            subItems.append(row)
            sortedDict[firstLetter] = subItems
        }
        
        return sortedDict
    }
    
    private var _contextMenuContentProvider: Any? = nil
    
    @available(iOS 13.0, *)
    /// Provides a callback which can create a `UIContextMenuConfiguration` to avoid the need to subclass `TableRow` to implement `contextMenuConfiguration`
    public var contextMenuConfigurationProvider: ContextMenuConfigurationProvider? {
        get {
            return _contextMenuContentProvider as? ContextMenuConfigurationProvider
        }
        set {
            _contextMenuContentProvider = newValue
        }
    }
    
    private var _contextMenuPreviewProvider: Any? = nil
    
    @available(iOS 13.0, *)
    /// Provides a callback which can create a `UIContextMenuConfiguration` to avoid the need to subclass `TableRow` to implement `contextMenuConfiguration`
    public var contextMenuPreviewProvider: TargetedPreviewProvider? {
        get {
            return _contextMenuPreviewProvider as? TargetedPreviewProvider
        }
        set {
            _contextMenuPreviewProvider = newValue
        }
    }
    
    @available(iOS 13.0, *)
    public func sectionContextMenuConfiguration(at point: CGPoint, for indexPath: IndexPath, in tableView: UITableView) -> UIContextMenuConfiguration? {
        return contextMenuConfigurationProvider?(point, indexPath, tableView)
    }
    
    @available(iOS 13.0, *)
    public func sectionPreviewForDismissingContextMenu(with configuration: UIContextMenuConfiguration, at indexPath: IndexPath, in tableView: UITableView) -> UITargetedPreview? {
        return contextMenuPreviewProvider?(configuration, false, indexPath, tableView)
    }
    
    @available(iOS 13.0, *)
    public func sectionPreviewForHighlightingContextMenu(with configuration: UIContextMenuConfiguration, at indexPath: IndexPath, in tableView: UITableView) -> UITargetedPreview? {
        return contextMenuPreviewProvider?(configuration, true, indexPath, tableView)
    }
}
