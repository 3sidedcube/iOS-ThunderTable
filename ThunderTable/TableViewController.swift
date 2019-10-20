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

open class TableViewController: UITableViewController {
    
    private var _data: [Section] = []
    
    open var data: [Section] {
        set {
            _data = newValue
            tableView.reloadData()
        }
        get {
            return _data
        }
    }
	
	public var selectedIndexPath: IndexPath?
	
	public var selectedRows: [Row]? {
		return tableView.indexPathsForSelectedRows?.map({ (indexPath) -> Row in
			return _data[indexPath.section].rows[indexPath.row]
		})
	}
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        let defaultNib = UINib(nibName: "TableViewCell", bundle: Bundle(for: TableViewController.self))
        tableView.register(defaultNib, forCellReuseIdentifier: "Cell")
    }
	
	private var dynamicChangeObserver: NSObjectProtocol?
	
	public var shouldRedrawWithContentSizeChange = true
	
	open override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		dynamicChangeObserver = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: self, queue: .main) { [weak self] (notification) in
			guard let strongSelf = self, strongSelf.shouldRedrawWithContentSizeChange else { return }
			strongSelf.tableView.reloadData()
		}
	}
	
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		guard let dynamicChangeObserver = dynamicChangeObserver else { return }
		NotificationCenter.default.removeObserver(dynamicChangeObserver)
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
        
        if let rowSubtitle = row.subtitle {
            detailLabel?.text = rowSubtitle
        } else {
            detailLabel?.text = nil
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
        
        imageView?.set(imageURL: row.imageURL, withPlaceholder: row.image, imageSize: size, animated: true, completion: { [weak self] (image, error) -> (Void) in
            
            if let welf = self, _row.image == nil {
                _row.image = image
                welf.tableView.reloadRows(at: [indexPath], with: .none)
            }
        })
		
		textLabel?.paragraphStyle = ThemeManager.shared.theme.cellTitleParagraphStyle
		detailLabel?.paragraphStyle = ThemeManager.shared.theme.cellDetailParagraphStyle
		
        row.configure(cell: cell, at: indexPath, in: self)
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
		let row = data[indexPath.section].rows[indexPath.row]
		return row.isEditable
	}
	
	override open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		let section = data[indexPath.section]
		let row = section.rows[indexPath.row]
		
		// Row edit handler overrides section edit handler
		if let rowEditHandler = row.editHandler {
			rowEditHandler(row, editingStyle, indexPath, tableView)
		} else if let sectionEditHandler = section.editHandler {
			sectionEditHandler(row, editingStyle, indexPath, tableView)
		}
	}
	
	open override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		let section = data[indexPath.section]
		let row = section.rows[indexPath.row]
		
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
		
		let section = data[indexPath.section]
		let row = section.rows[indexPath.row]
		
		guard let configuration = row.leadingSwipeActionsConfiguration ?? section.rowLeadingSwipeActionsConfiguration else { return nil }
		
		return configuration.configurationFor(row: row, at: indexPath, in: tableView)
	}
	
	@available(iOS 11.0, *)
	override open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let section = data[indexPath.section]
		let row = section.rows[indexPath.row]
		
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
        
        let row = _data[indexPath.section].rows[indexPath.row]
        
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
        
        let row = _data[indexPath.section].rows[indexPath.row]
        
        if let estimatedHeight = row.estimatedHeight {
            return estimatedHeight
        } else {
            return self.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    var dynamicHeightCells: [String: UITableViewCell] = [:]
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = _data[indexPath.section].rows[indexPath.row]
        
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
		
		let section = _data[section]
		return section.header
	}
	
	override open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
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
		
        let section = _data[indexPath.section]
        let row = section.rows[indexPath.row]
        
        return row.selectionHandler != nil || section.selectionHandler != nil || (row as? InputRow) != nil
    }
    
    internal func set(indexPath: IndexPath, selected: Bool) {
        
        let section = _data[indexPath.section]
        let row = section.rows[indexPath.row]
        
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
