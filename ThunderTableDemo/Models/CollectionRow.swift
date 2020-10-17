//
//  CollectionRow.swift
//  ThunderTableDemo
//
//  Created by Simon Mitchell on 02/09/2020.
//  Copyright © 2020 3SidedCube. All rights reserved.
//

import UIKit
import ThunderTable

class CollectionRow: NSObject, Row, UICollectionViewDataSource {
        
    let colours: [UIColor]
    
    init(colours: [UIColor]) {
        self.colours = colours
        super.init()
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        guard let collectionCell = cell as? CollectionTableViewCell else { return }
        
        collectionCell.collectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colours.count
    }
    
    var cellClass: UITableViewCell.Type? {
        return CollectionTableViewCell.self
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = colours[indexPath.item]
        return cell
    }
}
