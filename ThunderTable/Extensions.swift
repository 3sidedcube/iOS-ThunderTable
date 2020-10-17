//
//  Extensions.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 02/08/2017.
//  Copyright © 2017 3SidedCube. All rights reserved.
//

import Foundation

extension Array where Element == Section {
    
    /// Returns the full set of index paths that cover the array of sections
    var indexPaths: [IndexPath] {
        return enumerated().map { (offset, element) -> [IndexPath] in
            let rows = element.rows
            return (0..<rows.count).map { (row) -> IndexPath in
                return IndexPath(row: row, section: offset)
            }
        }.flatMap({ $0 })
    }
}

extension Array : Section {
    
    public var rows: [Row] {
        return filter({ (item) -> Bool in
            return item is Row
        }) as? [Row] ?? []
    }
    
    public var editHandler: EditHandler? {
        return nil
    }
    
    public var selectionHandler: SelectionHandler? {
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
    
    public var title: String? {
        return self
    }
}
