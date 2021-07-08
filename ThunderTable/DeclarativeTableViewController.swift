//
//  DeclarativeTableViewController.swift
//  ThunderTable
//
//  Created by Ben Shutt on 10/06/2021.
//  Copyright © 2021 3SidedCube. All rights reserved.
//

import Foundation
import UIKit

/// A `TableViewController` which uses `DeclarativeSection`.
///
/// - Note: If we implement both
/// - `tableView(_:titleForHeaderInSection:)` and
/// - `tableView(_:viewForHeaderInSection:)`
/// then `tableView(_:viewForHeaderInSection:)` takes priority (similarly for footers).
///
/// As `TableViewController` is already implementing `tableView(_:titleForHeaderInSection:)`
/// it would be a breaking change to add this `DeclarativeSection` logic on there.
/// Hence we create a new subclass.
open class DeclarativeTableViewController: TableViewController {

    // MARK: - Header

    override open func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        guard let tableSection = data[section] as? DeclarativeSection else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        return tableSection.headerHeight
    }

    override open func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard let tableSection = data[section] as? DeclarativeSection else {
            return super.tableView(tableView, viewForHeaderInSection: section)
        }
        return tableSection.headerView
    }

    override open func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return nil
    }

    // MARK: - Footer

    override open func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        guard let tableSection = data[section] as? DeclarativeSection else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
        return tableSection.footerHeight
    }

    override open func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        guard let tableSection = data[section] as? DeclarativeSection else {
            return super.tableView(tableView, viewForFooterInSection: section)
        }
        return tableSection.footerView
    }

    override open func tableView(
        _ tableView: UITableView,
        titleForFooterInSection section: Int
    ) -> String? {
        return nil
    }
}
