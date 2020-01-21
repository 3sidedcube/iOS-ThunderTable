//
//  Extensions.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 02/08/2017.
//  Copyright © 2017 3SidedCube. All rights reserved.
//

import UIKit

extension Array : Section {
    
    public var rows: [AnyRow] {
        return filter({ (item) -> Bool in
            return item is AnyRow
        }) as? [AnyRow] ?? []
    }
    
    public var editHandler: AnyEditHandler? {
        return nil
    }
    
    public var selectionHandler: AnySelectionHandler? {
        return nil
    }
}

extension String: PickerRowDisplayable {
    
    public var rowTitle: String {
        return self
    }
    
    public var value: AnyHashable {
        return self
    }
}

extension Int: PickerRowDisplayable {
    
    public var rowTitle: String {
        return "\(self)"
    }
    
    public var value: AnyHashable {
        return self
    }
}

extension Double: PickerRowDisplayable {
    
    public var rowTitle: String {
        return "\(self)"
    }
    
    public var value: AnyHashable {
        return self
    }
}

extension String : Row {
    
    public var selectionHandler: (String, Bool, IndexPath, UITableView) -> (Void)? {
        return nil
    }
    
    public func configure(cell: TableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
    }
    
    public typealias CellClass = TableViewCell
    
    public var title: String? {
        return self
    }
    
    public var cellClass: TableViewCell.Type? {
        return TableViewCell.self
    }
}
