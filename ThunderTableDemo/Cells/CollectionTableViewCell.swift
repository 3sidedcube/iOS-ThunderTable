//
//  CollectionTableViewCell.swift
//  ThunderTableDemo
//
//  Created by Simon Mitchell on 02/09/2020.
//  Copyright © 2020 3SidedCube. All rights reserved.
//

import UIKit
import ThunderTable

class CollectionTableViewCell: UITableViewCell, ScrollOffsetManagable, UICollectionViewDelegate {
    
    var scrollView: UIScrollView? {
        return collectionView
    }
    
    weak var scrollDelegate: ScrollOffsetDelegate?
    
    var identifier: AnyHashable?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidChangeContentOffset(self)
    }
}
