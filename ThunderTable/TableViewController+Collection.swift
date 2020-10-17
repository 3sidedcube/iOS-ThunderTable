//
//  TableViewController+Collection.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 04/12/2019.
//  Copyright © 2019 3SidedCube. All rights reserved.
//

import Foundation

extension TableViewController {
    
    //MARK: - Subscript Functions
    
    public subscript (index: IndexPath) -> (section: Section, row: Row)? {
        
        guard index.section < data.count else {
            return nil
        }
        
        let section = data[index.section]
        guard index.row < section.rows.count else {
            return nil
        }
        
        return (section, section.rows[index.row])
    }
    
    public subscript (row index: IndexPath) -> Row? {
        return self[index]?.row
    }
    
    public subscript (section index: IndexPath) -> Section? {
        
        guard index.section < data.count else {
            return nil
        }
        
        return data[index.section]
    }
    
    /// forEach Array equivalant for looping across all sections and rows of current `data`
    /// - Parameter body: A closure that takes each row, indexPath and section as the parameters.
    public func forEachRow(_ body: (Row, IndexPath, Section) -> Void) {
        
        data.enumerated().forEach { (sectionIndex, section) in
            section.rows.enumerated().forEach { (rowIndex, row) in
                body(row, IndexPath(row: rowIndex, section: sectionIndex), section)
            }
        }
    }
}
