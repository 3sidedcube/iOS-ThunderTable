//
//  ScrollOffsetManager.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 02/09/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import CoreGraphics
import Foundation

/// Scroll offset manager manages caching scroll offsets for UI in any scenario where
/// scroll views may be re-used and so we need to store their current offset in memory
/// to avoid re-use issues.
class ScrollOffsetManager {
    
    /// Internal cache for scroll view offsets
    private var offsetMap: [AnyHashable : CGPoint] = [:]
    
    /// Registers the scrollable to the manager for listening for scroll offset changes
    /// - Parameters:
    ///   - scrollable: The scrollable to register
    func register(
        scrollable: ScrollOffsetManagable
    ) {
        scrollable.scrollDelegate = self
    }
    
    /// Caches the offset for the given scrollable
    /// - Parameters:
    ///   - scrollable: The scrollable to update the content offset for
    func updateCachedOffset(scrollable: ScrollOffsetManagable) {
        guard let identifier = scrollable.identifier else { return }
        offsetMap[identifier] = scrollable.scrollView?.contentOffset
    }
    
    /// Sets the content offset on the given scrollable from the internal cache
    /// - Parameters:
    ///   - scrollable: The scrollable to adjust the content offset on
    ///   - animated: Whether the transition should animate
    ///   - fallback: A fallback to set the content offset to if there is no cached value
    func setScrollOffset(
        _ scrollable: ScrollOffsetManagable,
        animated: Bool = false,
        fallback: CGPoint? = nil
    ) {
        guard let identifier = scrollable.identifier else { return }
        guard let newOffset = offsetMap[identifier] ?? fallback else { return }
        
        guard let scrollView = scrollable.scrollView else { return }
        
        // Disable then re-enable scroll indicators otherwise calling setContentOffset flashes the scroll indicators
        let preShowVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator
        let preShowHorizontalScrollIndicator = scrollView.showsHorizontalScrollIndicator
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.setContentOffset(newOffset, animated: animated)
        
        scrollView.showsVerticalScrollIndicator = preShowVerticalScrollIndicator
        scrollView.showsHorizontalScrollIndicator = preShowHorizontalScrollIndicator
    }
    
    /// Resets all content offsets by removing them from the offset map
    func resetAllOffsets() {
        offsetMap = [:]
    }
}

extension ScrollOffsetManager: ScrollOffsetDelegate {
    
    func scrollViewDidChangeContentOffset(_ scrollable: ScrollOffsetManagable) {
        updateCachedOffset(scrollable: scrollable)
    }
}
