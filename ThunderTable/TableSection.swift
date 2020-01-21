//
//  TableSection.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 14/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit

public typealias AnySelectionHandler = (_ row: AnyRow, _ selected: Bool, _ indexPath: IndexPath, _ tableView: UITableView) -> (Void)

public typealias AnyEditHandler = (_ row: AnyRow, _ editingStyle: UITableViewCell.EditingStyle, _ indexPath: IndexPath, _ tableView: UITableView) -> (Void)

public protocol Section {
    
    var rows: [AnyRow] { get }
    
    var header: String? { get }
    
    var footer: String? { get }
    
    var editHandler: AnyEditHandler? { get }
    
    var selectionHandler: AnySelectionHandler? { get }
    
    var rowLeadingSwipeActionsConfiguration: SwipeActionsConfigurable? { get }
    
    var rowTrailingSwipeActionsConfiguration: SwipeActionsConfigurable? { get }
}

public extension Section {
    
    var rows: [AnyRow] {
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
}

open class TableSection: Section {
    
    open var header: String?
    
    open var footer: String?
    
    open var rows: [AnyRow]
    
    open var selectionHandler: AnySelectionHandler?
    
    open var editHandler: AnyEditHandler?
    
    open var rowLeadingSwipeActionsConfiguration: SwipeActionsConfigurable?
    
    open var rowTrailingSwipeActionsConfiguration: SwipeActionsConfigurable?
    
    public init(rows: [AnyRow], header: String? = nil, footer: String? = nil, selectionHandler: AnySelectionHandler? = nil) {
        
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
    public class func sortedSections(with rows: [AnyRow], selectionHandler: AnySelectionHandler? = nil) -> [TableSection] {
        
        let sortedAlphabetically = self.alphabeticallySort(rows: rows)
        let sortedKeys = sortedAlphabetically.keys.sorted { (stringA, stringB) -> Bool in
            return stringB > stringA
        }
        
        return sortedKeys.compactMap({key -> TableSection? in
            guard let rows = sortedAlphabetically[key] else { return nil }
            return TableSection(rows: rows, header: key, footer: nil, selectionHandler: selectionHandler)
        })
    }
    
    private class func alphabeticallySort(rows: [AnyRow]) -> [String : [AnyRow]] {
        
        var sortedDict = [String : [AnyRow]]()
        
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
}
