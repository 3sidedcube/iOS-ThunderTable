//
//  CNContact+Section.swift
//  ThunderTableDemo
//
//  Created by Simon Mitchell on 25/02/2019.
//  Copyright © 2019 3SidedCube. All rights reserved.
//

import Foundation
import Contacts
import ThunderTable

extension CNContact: Section {
    
    public var editHandler: EditHandler? {
        return nil
    }
    
    public var selectionHandler: SelectionHandler? {
        return nil
    }
    
    public var rows: [AnyRow] {
        
        let _rows: [AnyRow] = [
            AnyRow(TableRow(title: CNContact.localizedString(forKey: CNContactGivenNameKey), subtitle: givenName, image: nil, selectionHandler: nil)),
            AnyRow(TableRow(title: CNContact.localizedString(forKey: CNContactFamilyNameKey), subtitle: familyName, image: nil, selectionHandler: nil))
        ]
        
        return _rows
    }
}
