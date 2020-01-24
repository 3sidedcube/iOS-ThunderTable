//
//  TableRow.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 14/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit


/// Wrapper `AnyRow`
public struct AnyRow {
    
    private let _accessoryType: () -> UITableViewCell.AccessoryType?
    
    private let _configure: (_ cell: UITableViewCell, _ indexPath: IndexPath, _ tableViewController: TableViewController) -> Void
    
    private let _selectionStyle: () -> UITableViewCell.SelectionStyle?
    
    private let _title: () -> String?
    
    private let _displaySeparators: () -> Bool
    
    private let _cellStyle: () -> UITableViewCell.CellStyle?
    
    private let _accessibilityTitle: () -> String?
    
    private let _subtitle: () -> String?
    
    private let _accessibilitySubtitle: () -> String?
    
    private let _getImage: () -> UIImage?
    
    private let _setImage: (_ image: UIImage?) -> Void
    
    private let _imageSize: () -> CGSize?
    
    private let _imageURL: () -> URL?
    
    private let _remainSelected: () -> Bool
    
    private let _isEditable: () -> Bool
    
    private let _cellClass: () -> UITableViewCell.Type?
    
    private let _prototypeIdentifier: () -> String?
    
    private let _selectionHandler: () -> AnySelectionHandler?
    
    private let _editHandler: () -> AnyEditHandler?
    
    private let _estimatedHeight: () -> CGFloat?
    
    private let _padding: () -> CGFloat?
    
    private let _useNibSuperclass: () -> Bool
    
    private let _height: (_ constrainedToSize: CGSize, _ tableView: UITableView) -> CGFloat?
    
    private let _leadingSwipeActionsConfiguration: () -> SwipeActionsConfigurable?
    
    private let _trailingSwipeActionsConfiguration: () -> SwipeActionsConfigurable?
    
    public init<R: Row>(_ row: R)  {
        var _row = row
        _accessoryType = {
            return row.accessoryType
        }
        _selectionStyle = {
            return row.selectionStyle
        }
        _configure = { (cell, indexPath, tableViewController) in
            guard let correctCell = cell as? R.CellClass else { return }
            row.configure(cell: correctCell, at: indexPath, in: tableViewController)
        }
        _title = {
            return row.title
        }
        _displaySeparators = {
            return row.displaySeparators
        }
        _cellStyle = {
            return row.cellStyle
        }
        _accessibilityTitle = {
            return row.accessibilityTitle
        }
        _subtitle = {
            return row.subtitle
        }
        _accessibilitySubtitle = {
            return row.accessibilitySubtitle
        }
        _getImage = {
            return row.image
        }
        _setImage = { image in
            _row.image = image
        }
        _imageSize = {
            return row.imageSize
        }
        _imageURL = {
            return row.imageURL
        }
        _remainSelected = {
            return row.remainSelected
        }
        _isEditable = {
            return row.isEditable
        }
        _cellClass = {
            return row.cellClass
        }
        _prototypeIdentifier = {
            return row.prototypeIdentifier
        }
        _selectionHandler = {
            return row.selectionHandler
        }
        _editHandler = {
            return row.editHandler
        }
        _estimatedHeight = {
            return row.estimatedHeight
        }
        _padding = {
            return row.padding
        }
        _useNibSuperclass = {
            return row.useNibSuperclass
        }
        _height = { (constrainedSize, tableView) in
            return row.height(constrainedTo: constrainedSize, in: tableView)
        }
        _leadingSwipeActionsConfiguration = {
            return row.leadingSwipeActionsConfiguration
        }
        _trailingSwipeActionsConfiguration = {
            return row.trailingSwipeActionsConfiguration
        }
    }
    
    internal var title: String? {
        return _title()
    }
    
    internal var accessoryType: UITableViewCell.AccessoryType? {
        return _accessoryType()
    }
    
    internal var selectionStyle: UITableViewCell.SelectionStyle? {
        return _selectionStyle()
    }
    
    internal func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        _configure(cell, indexPath, tableViewController)
    }
    
    internal var displaySeparators: Bool {
        return _displaySeparators()
    }
    
    internal var cellStyle: UITableViewCell.CellStyle? {
        return _cellStyle()
    }
    
    /// A string to be used as the accessibility label for the row title
    internal var accessibilityTitle: String? {
        return _accessibilityTitle()
    }
    
    /// A string to be displayed as the subtitle for the row
    internal var subtitle: String? {
        return _subtitle()
    }
    
    /// A string to be used as the accessibility label for the row subtitle
    internal var accessibilitySubtitle: String? {
        return _accessibilitySubtitle()
    }
    
    /// An image to be displayed in the row
    internal var image: UIImage? {
        get {
            return _getImage()
        }
        set {
            _setImage(newValue)
        }
    }
    
    /// The size of the image which will be displayed in the row
    ///
    /// This will be used when displaying an image using imageURL in order
    /// to layout the cell correctly before the image has loaded in.
    internal var imageSize: CGSize? {
        return _imageSize()
    }
    
    /// A url to load the image for the cell from
    internal var imageURL: URL? {
        return _imageURL()
    }
    
    /// Whether the cell should remain selected when pressed by the user
    ///
    /// Defaults to false
    internal var remainSelected: Bool {
        return _remainSelected()
    }
    
    /// Whether the row is editable (Shows delete/actions) on cell swipe
    ///
    /// Defaults to false
    internal var isEditable: Bool {
        return _isEditable()
    }
    
    /// The class for the `UITableViewCell` subclass for the cell
    internal var cellClass: UITableViewCell.Type? {
        return _cellClass()
    }
    
    /// A prototype identifier for a cell which is defined in a storyboard
    /// file, which this row will use
    internal var prototypeIdentifier: String? {
        return _prototypeIdentifier()
    }
    
    /// A closure which will be called when the row is pressed on in the table view
    internal var selectionHandler: AnySelectionHandler? {
        return _selectionHandler()
    }
    
    /// A closure which will be called when the row is edited in the table view
    internal var editHandler: AnyEditHandler? {
        return _editHandler()
    }
    
    /// The estimated height of the row
    ///
    /// Defaults to nil, this is ignored by cells which are layed out
    /// using interface builder
    internal var estimatedHeight: CGFloat? {
        return _estimatedHeight()
    }
    
    /// Padding to apply to the edges of the row
    ///
    /// This is ignored by cells which are layed out
    /// using interface builder
    internal var padding: CGFloat? {
        return _padding()
    }
    
    /// Whether if no nib was found with the same file name as `cellClass`
    /// (expected behaviour is to name your cell's xib the same file name as the
    /// class you return from `cellClass`), we should then find a xib for a
    /// superclass of `cellClass`
    ///
    /// Defaults to true, meaning all cells without their own xib will use
    /// a superclasses xib to layout, this will eventually come across the base
    /// cell class `TableViewCell` so if you wish to have a none Interface Builder
    /// row, then make sure to return false from this, or subclass from UITableViewCell rather than TableViewCell!
    internal var useNibSuperclass: Bool {
        return _useNibSuperclass()
    }
    
    /// A function which allows providing a manual height for a cell not layed
    /// out using Interface Builder
    ///
    /// - Parameters:
    ///   - size: The size which the row has available to it
    ///   - tableView: The table view which the row will be displayed in
    /// - Returns: The height (or nil, to have this ignored) the row should be displayed at
    internal func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
        return _height(size, tableView)
    }
    
    /// A configuration object which allows leading swipe actions to be attached to the row.
    internal var leadingSwipeActionsConfiguration: SwipeActionsConfigurable? {
        return _leadingSwipeActionsConfiguration()
    }
    
    /// A configuration object which allows trailing swipe actions to be attached to the row.
    internal var trailingSwipeActionsConfiguration: SwipeActionsConfigurable? {
        return _trailingSwipeActionsConfiguration()
    }
}

/// A protocol which allows the rendering of information into a cell within
/// a `UITableView` by providing a declarative view on the information to show
public protocol Row {
    
    associatedtype CellClass: UITableViewCell
    
    /// The accessory type to be displayed on the right of the cell for this row
    /// - Important: If you wish to return `.none` from this, make sure to use the long syntax:
    /// `UITableViewCellAccessoryType.none` otherwise the compiler will think you are returning
    /// `Optional.none` which is equivalent to nil and therefore will be ignored by `TableViewController`
    var accessoryType: UITableViewCell.AccessoryType? { get }
    
    /// The selection style to be applied when the cell for this row is pressed down
    /// - Important: If you wish to return `.none` from this, make sure to use the long syntax:
    /// `UITableViewCellSelectionStyle.none` otherwise the compiler will think you are returning
    /// `Optional.none` which is equivalent to nil and therefore will be ignored by `TableViewController`
    var selectionStyle: UITableViewCell.SelectionStyle? { get }
    
    /// The cell style of the cell for this row
    ///
    /// - Important: This will only take affect if you directly use TableRow, or subclass `TableViewCell` but don't use a xib based layout and return false from `useNibSuperclass`.
    var cellStyle: UITableViewCell.CellStyle? { get }
    
    /// A string to be displayed as the title for the row
    var title: String? { get }
    
    /// A string to be used as the accessibility label for the row title
    var accessibilityTitle: String? { get }
    
    /// A string to be displayed as the subtitle for the row
    var subtitle: String? { get }
    
    /// A string to be used as the accessibility label for the row subtitle
    var accessibilitySubtitle: String? { get }
    
    /// An image to be displayed in the row
    var image: UIImage? { get set }
    
    /// The size of the image which will be displayed in the row
    ///
    /// This will be used when displaying an image using imageURL in order
    /// to layout the cell correctly before the image has loaded in.
    var imageSize: CGSize? { get }
    
    /// A url to load the image for the cell from
    var imageURL: URL? { get }
    
    /// Whether the cell should remain selected when pressed by the user
    ///
    /// Defaults to false
    var remainSelected: Bool { get }
    
    /// Whether separators should be displayed on the cell
    ///
    /// Defaults to true
    var displaySeparators: Bool { get }
    
    /// Whether the row is editable (Shows delete/actions) on cell swipe
    ///
    /// Defaults to false
    var isEditable: Bool { get }
    
    /// The class for the `UITableViewCell` subclass for the cell
    var cellClass: CellClass.Type? { get }
    
    /// A prototype identifier for a cell which is defined in a storyboard
    /// file, which this row will use
    var prototypeIdentifier: String? { get }
    
    /// A closure which will be called when the row is pressed on in the table view
    var selectionHandler: AnySelectionHandler? { get }
    
    /// A closure which will be called when the row is edited in the table view
    var editHandler: AnyEditHandler? { get }
    
    /// The estimated height of the row
    ///
    /// Defaults to nil, this is ignored by cells which are layed out
    /// using interface builder
    var estimatedHeight: CGFloat? { get }
    
    /// Padding to apply to the edges of the row
    ///
    /// This is ignored by cells which are layed out
    /// using interface builder
    var padding: CGFloat? { get }
    
    /// Whether if no nib was found with the same file name as `cellClass`
    /// (expected behaviour is to name your cell's xib the same file name as the
    /// class you return from `cellClass`), we should then find a xib for a
    /// superclass of `cellClass`
    ///
    /// Defaults to true, meaning all cells without their own xib will use
    /// a superclasses xib to layout, this will eventually come across the base
    /// cell class `TableViewCell` so if you wish to have a none Interface Builder
    /// row, then make sure to return false from this, or subclass from UITableViewCell rather than TableViewCell!
    var useNibSuperclass: Bool { get }
    
    /// A function which will be called in `cellForRow:atIndexPath` delegate 
    /// method which can be used to provide custom overrides on your cell from
    /// the row controlling it
    ///
    /// - Parameters:
    ///   - cell: The cell which needs configuring
    ///   - indexPath: The index path which that cell is at
    ///   - tableViewController: The table view controller which the cell is in
    func configure(cell: CellClass, at indexPath: IndexPath, in tableViewController: TableViewController)
    
    /// A function which allows providing a manual height for a cell not layed
    /// out using Interface Builder
    ///
    /// - Parameters:
    ///   - size: The size which the row has available to it
    ///   - tableView: The table view which the row will be displayed in
    /// - Returns: The height (or nil, to have this ignored) the row should be displayed at
    func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat?
    
    /// A configuration object which allows leading swipe actions to be attached to the row.
    var leadingSwipeActionsConfiguration: SwipeActionsConfigurable? { get }
    
    /// A configuration object which allows trailing swipe actions to be attached to the row.
    var trailingSwipeActionsConfiguration: SwipeActionsConfigurable? { get }
}

extension Row {
    
    public var accessoryType: UITableViewCell.AccessoryType? {
        return nil
    }
    
    public var selectionStyle: UITableViewCell.SelectionStyle? {
        return nil
    }
    
    public var displaySeparators: Bool {
        return true
    }
    
    public var isEditable: Bool {
        return leadingSwipeActionsConfiguration != nil || trailingSwipeActionsConfiguration != nil || editHandler != nil
    }
    
    public var cellStyle: UITableViewCell.CellStyle? {
        return nil
    }
    
    public var title: String? {
        return nil
    }
    
    public var subtitle: String? {
        return nil
    }
    
    public var accessibilityTitle: String? {
        return nil
    }
    
    public var accessibilitySubtitle: String? {
        return nil
    }
    
    public var image: UIImage? {
        get { return nil }
        set {}
    }
    
    public var imageURL: URL? {
        return nil
    }
    
    public var imageSize: CGSize? {
        return nil
    }
    
    public var remainSelected: Bool {
        return false
    }
    
    public var prototypeIdentifier: String? {
        return nil
    }
    
    public var useNibSuperclass: Bool {
        return true
    }
    
    public var estimatedHeight: CGFloat? {
        return nil
    }
    
    public var padding: CGFloat? {
        return nil
    }
    
    public func configure(cell: CellClass, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
    }
    
    public func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
        return nil
    }
    
    public var leadingSwipeActionsConfiguration: SwipeActionsConfigurable? { return nil }
    
    public var trailingSwipeActionsConfiguration: SwipeActionsConfigurable? { return nil }
    
    public var selectionHandler: AnySelectionHandler? { return nil }
     
    public var editHandler: AnyEditHandler? { return nil }
}

/// A base class which can be subclassed providing a template for the `Row` protocol
open class TableRow: Row {
    
    public var selectionHandler: AnySelectionHandler?
    
    public var editHandler: AnyEditHandler?
        
    open var cellStyle: UITableViewCell.CellStyle?
    
    open var displaySeparators: Bool = true
    
    public var isEditable: Bool {
        return leadingSwipeActionsConfiguration != nil || trailingSwipeActionsConfiguration != nil || editHandler != nil
    }
        
    open var title: String?
    
    open var accessibilityTitle: String?
    
    open var titleTextColor: UIColor = ThemeManager.shared.theme.cellTitleColor
    
    open var subtitleTextColor: UIColor = ThemeManager.shared.theme.cellDetailColor
    
    open var subtitle: String?
    
    open var accessibilitySubtitle: String?
    
    open var image: UIImage?
    
    open var imageSize: CGSize?
    
    open var imageURL: URL? {
        didSet {
            image = nil
        }
    }
    
    open var prototypeIdentifier: String? {
        return nil
    }
        
    open var selectionStyle: UITableViewCell.SelectionStyle?
    
    open var accessoryType: UITableViewCell.AccessoryType?
    
    open var leadingSwipeActionsConfiguration: SwipeActionsConfigurable?
    
    open var trailingSwipeActionsConfiguration: SwipeActionsConfigurable?
    
    open var cellClass: UITableViewCell.Type? {
        guard let cellStyle = cellStyle else { return TableViewCell.self }
        switch cellStyle {
        case .default:
            return DefaultTableViewCell.self
        case .subtitle:
            return SubtitleTableViewCell.self
        case .value1:
            return Value1TableViewCell.self
        case .value2:
            return Value2TableViewCell.self
        @unknown default:
            return DefaultTableViewCell.self
        }
    }
    
    open var estimatedHeight: CGFloat? {
        return nil
    }
    
    open var padding: CGFloat? {
        return nil
    }
    
    open var remainSelected: Bool {
        return false
    }
    
    open var useNibSuperclass: Bool {
        return true
    }
    
    open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        guard let tableViewCell = cell as? TableViewCell else {
            return
        }
        
        if let imageView = tableViewCell.cellImageView {
            
            if image == nil && imageURL == nil {
                imageView.isHidden = true
            } else {
                imageView.isHidden = false
            }
        }
        
        tableViewCell.cellTextLabel?.textColor = titleTextColor
        tableViewCell.cellDetailLabel?.textColor = subtitleTextColor
    }
    
    public func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
        return nil
    }
    
    public init(title: String?, subtitle: String? = nil, image: UIImage? = nil, selectionHandler: AnySelectionHandler? = nil) {
        
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.selectionHandler = selectionHandler
    }
}
