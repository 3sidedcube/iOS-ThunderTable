//
//  ScrollDelegatable.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 02/09/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import UIKit

/// A simpler version of `UIScrollViewDelegate` so we don't intefere
/// with users `UIScrollViewDelegate` implementations
public protocol ScrollOffsetDelegate: class {
    
    /// Called when the content offset of the scroll view changes due to `scrollViewDidScroll`
    /// - Parameters:
    ///   - scrollable: The scrollable that the change was for
    func scrollViewDidChangeContentOffset(_ scrollable: ScrollOffsetManagable)
}

/// A protocol implemented to allow control and listening to scroll view offset changes
/// by `ScrollOfffsetManager`
public protocol ScrollOffsetManagable: class {
    
    /// The scroll view that is controllable on the object
    var scrollView: UIScrollView? { get }
    
    /// The delegate to have scroll view delegate methods passed to, this should be a `weak`
    /// property to avoid retain cycles.
    /// - Warning: It is your job to call the method on this delegate from your scrollViewDidScroll method.
    var scrollDelegate: ScrollOffsetDelegate? { get set }
    
    /// An identifier used by `ScrollOffsetManager`
    var identifier: AnyHashable? { get set }
}
