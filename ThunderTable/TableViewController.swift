//
//  TableViewController.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 14/09/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit

extension UILabel {
	
	var paragraphStyle: NSParagraphStyle? {
		set {
			
			if let text = text, let style = newValue?.mutableCopy() as? NSMutableParagraphStyle {
				
				var attributes = [NSAttributedString.Key : Any]()
				style.alignment = textAlignment
				
				if let font = font {
					attributes[.font] = font
				}
				
				if let textColor = textColor {
					attributes[.foregroundColor] = textColor
				}
				                
				attributes[.paragraphStyle] = style
				
				let attributedString = NSAttributedString(string: text, attributes: attributes)
				attributedText = attributedString
			}
		}
		get {
            guard let paragraphAttribute = attributedText?.attribute(.paragraphStyle, at: 0, effectiveRange: nil) else { return nil }
            return paragraphAttribute as? NSParagraphStyle
		}
	}
}

extension UITableViewCell.AccessoryType {
	
    var rightInset: CGFloat {
        switch self {
        case .none:
            return 0
        case .disclosureIndicator, .detailButton, .detailDisclosureButton, .checkmark:
            return 4
        @unknown default:
            return 0
        }
    }
}

extension Row {
    
    /// Returns a nib for the row's cell class if one exists in the bundle for the class
    var nib: UINib? {
        
        get {
            
            guard var cellClass = cellClass else { return nil }
            
            var classString = String(describing: cellClass)
            guard var nibName = classString.components(separatedBy: ".").last else { return nil }
						
            var bundle = Bundle(for: cellClass)
			var nibPath = bundle.path(forResource: nibName, ofType: "nib")
			
			// Only look for nib superclasses if we're told to by Row protocol
			if useNibSuperclass {
				
				// Sometimes a cell may have subclassed without providing it's own nib file
				// In this case always use it's superclass!
				while nibPath == nil, let superClass = cellClass.superclass() as? UITableViewCell.Type {
					
					// Make sure we're still looking in the correct bundle
					bundle = Bundle(for: superClass)
					// Find the new class name
					classString = String(describing: superClass)
					// Get the new nib name for the classes superClass
					if let superNibName = classString.components(separatedBy: ".").last, let path = bundle.path(forResource: superNibName, ofType: "nib") {
						// Update nibPath and nibName
						nibPath = path
						nibName = superNibName
					}
					cellClass = superClass
				}
			}
			
            guard nibPath != nil else { return nil }
            let nib = UINib(nibName: nibName, bundle: bundle)
            return nib
        }
    }
    
    var identifier: String? {
        
        if let prototypeIdentifier = prototypeIdentifier {
            return prototypeIdentifier
        } else if let cellClass = cellClass {
            return String(describing: cellClass)
        }
        
        return nil
    }
}

open class TableViewController: UITableViewController, UIContentSizeCategoryAdjusting {
    
    private var _data: [Section] = []
    
    open var data: [Section] {
        set {
            // If the table view has had rows removed/added
            if newValue.indexPaths != data.indexPaths {
                resetEmbeddedScrollOffsets()
            }
            _data = newValue
            guard reloadDataOnDataDidSet else { return }
            tableView.reloadData()
        }
        get {
            return _data
        }
    }

    /// When `true`, execute `tableView.reloadData()` on `didSet` of `data`.
    /// Subclasses which set this to `false` should handle the reloading of the `tableView` `Section`s
    /// and `Row`s itself.
    open var reloadDataOnDataDidSet = true
    
    /// The currently selected index path of the table view
	public var selectedIndexPath: IndexPath?
	
	public var selectedRows: [Row]? {
		return tableView.indexPathsForSelectedRows?.compactMap({ (indexPath) -> Row? in
            return self[row: indexPath]
		})
	}
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        let defaultNib = UINib(nibName: "TableViewCell", bundle: Bundle(for: TableViewController.self))
        tableView.register(defaultNib, forCellReuseIdentifier: "Cell")
    }
	
    private var dynamicChangeObserver: NSObjectProtocol?
    
    private var accessibilityObservers: [Any] = []
    
    /// Indicates whether the table view should redraw visible cells automatically when the device's UIContentSizeCategory is changed.
    public var adjustsFontForContentSizeCategory: Bool = true
    
    /// A list of notification names that should cause the table view to redraw itself
    public var accessibilityRedrawNotificationNames: [Notification.Name] = [
        UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
        UIAccessibility.boldTextStatusDidChangeNotification,
        UIAccessibility.grayscaleStatusDidChangeNotification,
        UIAccessibility.invertColorsStatusDidChangeNotification,
        UIAccessibility.reduceTransparencyStatusDidChangeNotification
    ]
	
	open override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		dynamicChangeObserver = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main) { [weak self] (notification) in
			guard let strongSelf = self, strongSelf.adjustsFontForContentSizeCategory else { return }
            strongSelf.reloadVisibleRowsWhilstMaintainingSelection()
            strongSelf.accessibilitySettingsDidChange()
		}
        
        var accessibilityNotifications: [Notification.Name] = [
            UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
            UIAccessibility.assistiveTouchStatusDidChangeNotification,
            UIAccessibility.boldTextStatusDidChangeNotification,
            UIAccessibility.grayscaleStatusDidChangeNotification,
            UIAccessibility.guidedAccessStatusDidChangeNotification,
            UIAccessibility.invertColorsStatusDidChangeNotification,
            UIAccessibility.reduceMotionStatusDidChangeNotification,
            UIAccessibility.reduceTransparencyStatusDidChangeNotification
        ]
            
        // Notification names that it makes sense to redraw on.
        // Note that these differ from `self.accessibilityRedrawNotificationNames`. It is easier, and not too
        // expensive to manage which notifications trigger a refresh at the point of receiving the notification
        // rather than risking double-adding or double-removing the observers!
        if #available(iOS 11.0, *) {
            accessibilityNotifications.append(UIAccessibility.voiceOverStatusDidChangeNotification)
        }
        
        accessibilityObservers = accessibilityNotifications.map({ (notificationName) -> Any in
            return NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: .main, using: { [weak self] (notification) in
                guard let strongSelf = self, strongSelf.accessibilityRedrawNotificationNames.contains(notification.name) else {
                    return
                }
                strongSelf.reloadVisibleRowsWhilstMaintainingSelection()
                strongSelf.accessibilitySettingsDidChange()
            })
        })
	}
	
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        accessibilityObservers.forEach { (observer) in
            NotificationCenter.default.removeObserver(observer)
        }
        accessibilityObservers = []
		guard let dynamicChangeObserver = dynamicChangeObserver else { return }
		NotificationCenter.default.removeObserver(dynamicChangeObserver)
        self.dynamicChangeObserver = nil
	}
    
    /// A function which does nothing, but provides a hook for `TableViewController`'s automatic
    /// refresh when accessibility settings change!
    open func accessibilitySettingsDidChange() {
        
    }
    
    public var inputDictionary: [String: Any] {
        
        guard let inputRows = _data.flatMap({ $0.rows.filter({ $0 as? InputRow != nil }) }) as? [InputRow] else { return [:] }
        
        var dictionary: [String: Any] = [:]
        
        inputRows.forEach { (row) in
            dictionary[row.id] = row.value
        }
        
        return dictionary
    }
	
	public var missingRequiredInputRows: [InputRow]? {
		
		guard let inputRows = _data.flatMap({ $0.rows.filter({ $0 as? InputRow != nil }) }) as? [InputRow] else { return nil }
		
		return inputRows.filter({ (inputRow) -> Bool in
			return inputRow.required && inputRow.value == nil
		})
	}
	
    private var registeredClasses: [String] = []

    // MARK: - Helper functions!
    
    private func reloadVisibleRowsWhilstMaintainingSelection() {
        
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        
        let selectedVisibleIndexPaths = tableView.indexPathsForSelectedRows?.filter({ visibleIndexPaths.contains($0) })
        tableView.reloadRows(at: visibleIndexPaths, with: .none)
        selectedVisibleIndexPaths?.forEach({ (indexPath) in
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        })
    }
    
    open func configure(cell: UITableViewCell, with row: Row, at indexPath: IndexPath) {
        
        var _row = row
        var textLabel = cell.textLabel
        var detailLabel = cell.detailTextLabel
        var imageView = cell.imageView
        
        if let tscTableCell = cell as? TableViewCell {
            
            textLabel = tscTableCell.cellTextLabel
            detailLabel = tscTableCell.cellDetailLabel
            imageView = tscTableCell.cellImageView
			
			tscTableCell.shouldDisplaySeparators = row.displaySeparators
			tscTableCell.cellStyle = row.cellStyle ?? .subtitle
        }
		
		// Whether to display cell separators
		if _row.displaySeparators {
			cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.separatorInset.left, bottom: 0, right: 0)
		} else {
			cell.separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0)
			cell.layoutMargins = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0)
		}
		
		
		cell.selectionStyle = row.selectionStyle ?? (selectable(indexPath) ? .default : .none)
		cell.accessoryType = row.accessoryType ?? (selectable(indexPath) ? .disclosureIndicator : .none)

        if let rowTitle = row.title {
            textLabel?.text = rowTitle
        } else {
            textLabel?.text = nil
        }
        
        if let rowAccessibilityTitle = row.accessibilityTitle {
            textLabel?.accessibilityLabel = rowAccessibilityTitle
        } else {
            textLabel?.accessibilityLabel = nil
        }
        
        if let rowSubtitle = row.subtitle {
            detailLabel?.text = rowSubtitle
        } else {
            detailLabel?.text = nil
        }
        
        if let rowAccessibilitySubtitle = row.accessibilitySubtitle {
            detailLabel?.accessibilityLabel = rowAccessibilitySubtitle
        } else {
            detailLabel?.accessibilityLabel = nil
        }
        
        if let rowImage = row.image {
            imageView?.image = rowImage
        } else {
            imageView?.image = nil
        }
        
        var size = CGSize.zero
        if let imageSize = row.imageSize {
            size = imageSize
        }
        
        // Only load image from url if we have an image url
        if let imageURL = row.imageURL {
            
            imageView?.set(imageURL: imageURL, withPlaceholder: row.image, imageSize: size, animated: true, completion: { [weak self] (image, error) -> (Void) in
                
                guard let self = self else { return }
                guard let image = image, _row.image == nil else { return }
                _row.image = image
                // Try and find matching index paths with the same imageURL and reload it.
                // We can't use `indexPath` provided to this function as it may have changed!
                self.reloadRows(where: { $0.imageURL == imageURL })
            })
        }
		
		textLabel?.paragraphStyle = ThemeManager.shared.theme.cellTitleParagraphStyle
		detailLabel?.paragraphStyle = ThemeManager.shared.theme.cellDetailParagraphStyle
        
        updateScrollPosition(cell: cell, at: indexPath)
		
        row.configure(cell: cell, at: indexPath, in: self)
    }
    
    /// Reloads all table rows where the row matches a certain predicate
    /// - Parameter predicate: The predicate to match rows based on
    /// - Parameter animation: The animation to run when reloading
    public func reloadRows(where predicate: (Row) -> Bool, with animation: UITableView.RowAnimation = .none) {
        
        var indexPathsToReload: [IndexPath] = []
        self.forEachRow { (row, indexPath, _) in
            guard predicate(row) else { return }
            indexPathsToReload.append(indexPath)
        }
        guard !indexPathsToReload.isEmpty else { return }
        self.tableView.reloadRows(at: indexPathsToReload, with: animation)
    }

    /// Execute `closure` with `reloadDataOnDataDidSet` set to `false`.
    /// Return `reloadDataOnDataDidSet` to it's previous value when closure returns
    ///
    /// - Parameter closure: Functionality to execute
    open func withoutReloading(closure: () -> Void) {
        let valueBefore = reloadDataOnDataDidSet

        reloadDataOnDataDidSet = false
        closure()
        reloadDataOnDataDidSet = valueBefore
    }
    
    private func register(row: Row) {
        
        guard let identifier = row.identifier else { return }
        
        if let nib = row.nib {
            tableView.register(nib, forCellReuseIdentifier: identifier)
        } else if let cellClass = row.cellClass {
            tableView.register(cellClass, forCellReuseIdentifier: identifier)
        }
		
		registeredClasses.append(identifier)
    }
    
    // MARK: - TableView data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        
        return _data.count
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section - 1 > _data.count { return 0 }
        
        let section = _data[section]
        return section.rows.count
    }

	override open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let row = self[row: indexPath] else { return false }
		return row.isEditable
	}
	
	override open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		guard let (section, row) = self[indexPath] else { return }
		
		// Row edit handler overrides section edit handler
		if let rowEditHandler = row.editHandler {
			rowEditHandler(row, editingStyle, indexPath, tableView)
		} else if let sectionEditHandler = section.editHandler {
			sectionEditHandler(row, editingStyle, indexPath, tableView)
		}
	}
	
	open override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		guard let (section, row) = self[indexPath] else { return [] }
		
		guard let configuration = row.trailingSwipeActionsConfiguration ?? section.rowTrailingSwipeActionsConfiguration else {
            
            // Returning nil gives us the default "delete" item, so we only return nil if we don't have an editHandler
            if section.editHandler == nil && row.editHandler == nil {
                return []
            }
            return nil
        }
		
		return configuration.rowActionsFor(row: row, in: tableView)
	}
	
	@available(iOS 11.0, *)
	override open func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
        guard let (section, row) = self[indexPath] else { return nil }
		
		guard let configuration = row.leadingSwipeActionsConfiguration ?? section.rowLeadingSwipeActionsConfiguration else { return nil }
		
		return configuration.configurationFor(row: row, at: indexPath, in: tableView)
	}
	
	@available(iOS 11.0, *)
	override open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		guard let (section, row) = self[indexPath] else { return nil }
		
		guard let configuration = row.trailingSwipeActionsConfiguration ?? section.rowTrailingSwipeActionsConfiguration else {
            
            // Returning nil gives us the default "delete" item, so we only return nil if we don't have an editHandler
            if section.editHandler == nil && row.editHandler == nil {
                let emptyConfiguration = UISwipeActionsConfiguration(actions: [])
                return emptyConfiguration
            }
            return nil
        }
		
		return configuration.configurationFor(row: row, at: indexPath, in: tableView)
	}
		
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let row = self[row: indexPath] else { return UITableViewCell() }
                
        var identifier: String = "Cell"
        
        // If the row defines a cell class use the identifier for that
        if let rowIdentifier: String = row.identifier {
            identifier = rowIdentifier
        }
        
        // If we don't have a prototype identifier (Prototype cells are automatically registered by the OS
        if row.prototypeIdentifier == nil {
            
            // Make sure it's registered before de-queueing it
            if !registeredClasses.contains(where: {identifier == $0}) {
                register(row: row)
            }
        }
        
        if identifier == "Cell" {
            print("You didn't provide a cellClass or prototypeIdentifier for \(row), falling back to our default cell class")
        }
		
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        configure(cell: cell, with: row, at: indexPath)
        
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let row = self[row: indexPath] else { return self.tableView(tableView, heightForRowAt: indexPath) }
        
        if let estimatedHeight = row.estimatedHeight {
            return estimatedHeight
        } else {
            return self.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    var dynamicHeightCells: [String: UITableViewCell] = [:]
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let row = self[row: indexPath] else { return UITableView.automaticDimension }
        
        // If they're using prototype cells or nibs then we don't want to manually calculate size
        let calculateSize = row.prototypeIdentifier == nil && row.nib == nil
        
        if !calculateSize {
            return UITableView.automaticDimension
        }
		
		if let height = row.height(constrainedTo: CGSize(width: tableView.frame.width, height: CGFloat.greatestFiniteMagnitude), in: tableView) {
			return height
		}
        
        // Let's calculate this mothertrucker!
        
        var identifier: String = "Cell"
        // If the row defines a cell class use the identifier for that
        if let rowIdentifier: String = row.identifier {
            identifier = rowIdentifier
        }
        
        var cell = dynamicHeightCells[identifier]
        if cell == nil {
            
            if let aClass = row.cellClass {
                cell = aClass.init(style: .default, reuseIdentifier: identifier)
            }
        }
        
        guard let _cell = cell else { return UITableView.automaticDimension }

        configure(cell: _cell, with: row, at: indexPath)
        
        _cell.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width - max(2.0, UIScreen.main.scale) * _cell.accessoryType.rightInset, height: 44)
        
        _cell.layoutSubviews()
        
        var totalHeight: CGFloat = 0;
        let subviews = _cell.contentView.subviews
        var lowestYValue: CGFloat = 0;
        
        subviews.forEach { (view) in
            
            if view.frame.height == 0 { return }
            
            let maxY = view.frame.maxY
            if maxY > totalHeight {
                totalHeight = maxY
            }
            
            let minY = view.frame.minY
            if minY < lowestYValue {
                lowestYValue = minY
            }
        }
        
        var cellHeight = totalHeight + abs(lowestYValue) + 8
        
        if let padding = row.padding {
            cellHeight = cellHeight - 8 + padding
        }
        
        cellHeight = ceil(cellHeight);
        return cellHeight;
    }
	
	override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < data.count else { return nil }
		let section = _data[section]
		return section.header
	}
	
	override open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section < data.count else { return nil }
		let section = _data[section]
		return section.footer
	}

    //MARK - Table View Delegate
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectable(indexPath) {
            set(indexPath: indexPath, selected: true)
        }
    }
    
    override open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectable(indexPath) {
            set(indexPath: indexPath, selected: false)
        }
    }
    
    //MARK: -
    //MARK: Scroll Offset Management
    //MARK:
    
    private let scrollOffsetManager: ScrollOffsetManager = ScrollOffsetManager()
    
    /// Whether the table view should keep track of scroll view positions within it's cells.
    /// This allows us to prevent re-use issues with re-using cells that the user has scrolled.
    /// To allow your cell's scroll position to be remembered you need to implement the `ScrollOffsetManagable`
    /// protocol on your `UITableViewCell` subclass.
    /// - Note: This will not handle re-ordering of cells at present, and if the length of your
    /// data changes (different numbers of rows in any section, or different number of sections)
    /// then the cached values will be reset. This may be improved in future if we decide to enforce
    /// row's being `Equatable`.
    public var rememberEmbeddedScrollPositions: Bool = true
    
    /// Resets all the "remembered" scroll offsets back to `.zero` for all embedded scrollable cells
    /// that conform to `ScrollOffsetManagable`.
    ///
    /// - Note: This will not actually perform any scrolling on the visible cells (Based on the value provided in `scrollVisibleCells`,
    /// but they will reset to `.zero` the next time that `cellForRow:` is called regardless of the value provided.
    /// - Parameter scrollVisibleCells: Whether to scroll the visible cells as well as resetting the cache. Defaults to `false`
    /// - Parameter animated: If `scrollVisibleCells == true`, whether we should animate the transition. Defaults to `false`
    public func resetEmbeddedScrollOffsets(scrollingVisibleCells: Bool = false, animated: Bool = false) {
        scrollOffsetManager.resetAllOffsets()
        guard scrollingVisibleCells else { return }
        tableView.visibleCells.forEach { (cell) in
            guard let scrollable = cell as? ScrollOffsetManagable else { return }
            scrollable.scrollView?.setContentOffset(.zero, animated: animated)
        }
    }
    
    /// Updates the scroll position for the given cell, storing it in `scrollOffsetManager` and actually setting the contentOffset
    /// - Parameters:
    ///   - cell: The cell to update scroll for
    ///   - indexPath: The index path that the cell is at
    ///   - animated: Whether to animate the setting of scroll offset
    func updateScrollPosition(cell: UITableViewCell, at indexPath: IndexPath, animated: Bool = false) {
        
        guard rememberEmbeddedScrollPositions, let scrollable = cell as? ScrollOffsetManagable else { return }
        
        // Set the identifier on the scrollable so it can be tracked. Use `indexPath` for this
        scrollable.identifier = indexPath
        // Register the scrollable so it's offset is tracked
        scrollOffsetManager.register(scrollable: scrollable)
        // Set the scroll offset based on `scrollOffsetManager`. This fixes scroll re-use issues.
        scrollOffsetManager.setScrollOffset(scrollable, animated: animated, fallback: .zero)
    }
    
	//MARK - variable header/footer size
	
	private var headerTranslatesAutoResizingMask: Bool = false
	private var footerTranslatesAutoResizingMask: Bool = false
	
	public func sizeHeaderToFit() {
		
		guard let headerView = tableView.tableHeaderView else { return }
		
		// Disable autoresizing mask into constraints to stop the view from being constrained to the height defined in IB
		headerTranslatesAutoResizingMask = headerView.translatesAutoresizingMaskIntoConstraints
		headerView.translatesAutoresizingMaskIntoConstraints = false
		sizeToFit(view: headerView)
		tableView.tableHeaderView = headerView
		headerView.translatesAutoresizingMaskIntoConstraints = headerTranslatesAutoResizingMask
	}
	
	public func sizeFooterToFit() {
		
		guard let footerView = tableView.tableFooterView else { return }
		
		// Disable autoresizing mask into constraints to stop the view from being constrained to the height defined in IB
		footerTranslatesAutoResizingMask = footerView.translatesAutoresizingMaskIntoConstraints
		footerView.translatesAutoresizingMaskIntoConstraints = false
		sizeToFit(view: footerView)
		tableView.tableFooterView = footerView
		footerView.translatesAutoresizingMaskIntoConstraints = headerTranslatesAutoResizingMask
	}
	
	private func sizeToFit(view: UIView) {
		
		// Because we've disabled translatesAutoresizingMaskIntoConstraints we need to add a temporary constraint for the width of the view
		let width = view.bounds.width
		let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[view(width)]", options: [], metrics: ["width": width], views: ["view": view])
		view.addConstraints(temporaryWidthConstraints)
		
		// Now do the view height calculation
		view.setNeedsLayout()
		view.layoutIfNeeded()
		
		let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		let height = size.height
		var frame = view.frame
		
		frame.size.height = height
		view.frame = frame
		
		view.removeConstraints(temporaryWidthConstraints)
	}
}


//MARK - Selection
public extension TableViewController {
	
    internal func selectable(_ indexPath: IndexPath) -> Bool {
        guard let (section, row) = self[indexPath] else { return false }
        return row.selectionHandler != nil || section.selectionHandler != nil || (row as? InputRow) != nil
    }
    
    internal func set(indexPath: IndexPath, selected: Bool) {
        
        guard let (section, row) = self[indexPath] else { return }
        
        // Row selection overrides section selection
        if let rowSelectionHandler = row.selectionHandler {
            rowSelectionHandler(row, selected, indexPath, tableView)
        } else if let sectionSelectionHandler = section.selectionHandler {
            sectionSelectionHandler(row, selected, indexPath, tableView)
        }
		
        // Deselect it if remain selected is false
        if selected && !row.remainSelected {
            tableView.deselectRow(at: indexPath, animated: true)
		} else if selected && row.remainSelected {
			selectedIndexPath = indexPath
		}
			
        if row is InputRow, selected {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.becomeFirstResponder()
        }
    }
    
    func moveToInputCell(after indexPath: IndexPath) {
        
        outerLoop: for (sectionIndex, section) in data.enumerated() {
            
            if sectionIndex >= indexPath.section {
                
                for (rowIndex, row) in section.rows.enumerated() {
                    
                    if row is InputRow, rowIndex > indexPath.row {
                        
                        let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        set(indexPath: indexPath, selected: true)
                        
                        break outerLoop
                    }
                }
            }
        }
    }
}
