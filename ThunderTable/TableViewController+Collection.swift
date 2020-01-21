//
//  TableViewController+Collection.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 04/12/2019.
//  Copyright © 2019 3SidedCube. All rights reserved.
//

import Foundation

extension TableViewController {
    
    public subscript (index: IndexPath) -> (section: Section, row: AnyRow)? {
        
        guard index.section < data.count else {
            return nil
        }
        
        let section = data[index.section]
        guard index.row < section.rows.count else {
            return nil
        }
        
        return (section, section.rows[index.row])
    }
    
    public subscript (row index: IndexPath) -> AnyRow? {
        return self[index]?.row
    }
    
    public subscript (section index: IndexPath) -> Section? {
        
        guard index.section < data.count else {
            return nil
        }
        
        return data[index.section]
    }
}
