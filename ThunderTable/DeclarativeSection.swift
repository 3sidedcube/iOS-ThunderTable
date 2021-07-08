//
//  DeclarativeSection.swift
//  ThunderTable
//
//  Created by Ben Shutt on 01/02/2021.
//  Copyright © 2021 3SidedCube. All rights reserved.
//

import Foundation
import UIKit

/// A `TableSection` with a header and footer specified
open class DeclarativeSection: TableSection {

    /// `CGFloat` height of the header for `Section`
    open var headerHeight: CGFloat

    /// `UIView` view of the header for `Section`
    open var headerView: UIView

    /// `CGFloat` height of the footer for `Section`
    open var footerHeight: CGFloat

    /// `UIView` view of the footer for `Section`
    open var footerView: UIView

    /// Default memberwise initializer
    ///
    /// - Parameters:
    ///   - rows: `[Row]`
    ///   - headerHeight: `CGFloat`
    ///   - headerView: `UIView`
    ///   - footerHeight: `CGFloat`
    ///   - footerView: `UIView`
    public init(
        rows: [Row],
        headerHeight: CGFloat = 0,
        headerView: UIView = UIView(),
        footerHeight: CGFloat = 0,
        footerView: UIView = UIView()
    ) {
        self.headerHeight = headerHeight
        self.headerView = headerView
        self.footerHeight = footerHeight
        self.footerView = footerView

        super.init(rows: rows)
    }
}
