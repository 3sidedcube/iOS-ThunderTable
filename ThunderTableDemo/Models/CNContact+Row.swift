//
//  CNContact+Row.swift
//  ThunderTableDemo
//
//  Created by Simon Mitchell on 02/03/2018.
//  Copyright © 2018 3SidedCube. All rights reserved.
//

import UIKit
import Contacts
import ThunderTable

extension CNContact: Row {
    
    public var cellClass: ContactTableViewCell.Type? {
        return ContactTableViewCell.self
    }
    
    public typealias CellClass = ContactTableViewCell
        
    public var title: String? {
        return givenName + " " + familyName
    }
    
    public var subtitle: String? {
        return phoneNumbers.first?.value.stringValue
    }
    
    public var image: UIImage? {
        get {
            guard let thumbnailImageData = thumbnailImageData else { return nil }
            return UIImage(data: thumbnailImageData)
        }
        set { }
    }
    
//    public func configure(cell: ContactTableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
//        cell.cellImageView?.isHidden = image == nil
//    }
}
