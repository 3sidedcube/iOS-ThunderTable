//
//  ImageView.swift
//  ThunderTable
//
//  Created by Simon Mitchell on 06/10/2016.
//  Copyright © 2016 3SidedCube. All rights reserved.
//

import UIKit
import ObjectiveC

public typealias ImageViewSetImageURLCompletion = (_ image: UIImage?,_  error: Error?) -> (Void)

private var finalSizeKey: UInt8 = 0
private var completionKey: UInt8 = 1
private var showingPlaceholderKey: UInt8 = 2
private var imageUrlsKey: UInt8 = 3
private var requestsKey: UInt8 = 4

private class ImageClosureWrapper {
    
    var closure: ImageViewSetImageURLCompletion?
    
    init(closure: ImageViewSetImageURLCompletion?) {
        self.closure = closure
    }
}

/// A subclass of ImageView to improve intrinsicContentSize behaviour
public class ImageView: UIImageView {
	
	override public var intrinsicContentSize: CGSize {
		if finalSize == .zero {
			
			if super.intrinsicContentSize.width == -1.0 || super.intrinsicContentSize.height == -1.0 {
				return .zero
			} else {
				return super.intrinsicContentSize
			}
			
		} else {
			return finalSize
		}
	}
}

// MARK: - An extension on UIImageView for loading images from urls
public extension UIImageView {
    
    private struct AssociatedKeys {
        static var finalSizeKey = "final_size"
        static var completionKey = "completion"
        static var showingPlaceholderKey = "showing_placeholder"
        static var imageUrlsKey = "image_urls"
        static var requestsKey = "requests"
    }
    
    /// The size of the image that will be loaded
    var finalSize: CGSize {
        get {
            guard let sizeValue = objc_getAssociatedObject(self, &finalSizeKey) as? NSValue else { return CGSize.zero }
            return sizeValue.cgSizeValue
        }
        set {
            objc_setAssociatedObject(self, &finalSizeKey, NSValue(cgSize: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var completion: ImageViewSetImageURLCompletion? {
        get {
            guard let wrapper = objc_getAssociatedObject(self, &completionKey) as? ImageClosureWrapper else { return nil }
            return wrapper.closure
        }
        set {
            objc_setAssociatedObject(self, &completionKey, ImageClosureWrapper(closure: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var showingPlaceholder: Bool {
        get {
            guard let showing = objc_getAssociatedObject(self, &showingPlaceholderKey) as? NSNumber else { return false }
            return showing.boolValue
        }
        set {
            objc_setAssociatedObject(self, &showingPlaceholderKey, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var imageURLS: [URL]? {
        get {
            return objc_getAssociatedObject(self, &imageUrlsKey) as? [URL]
        }
        set {
            objc_setAssociatedObject(self, &imageUrlsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var requests: [ImageRequest]? {
        get {
            return objc_getAssociatedObject(self, &requestsKey) as? [ImageRequest]
        }
        set {
            objc_setAssociatedObject(self, &requestsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Loads an image from the given URL and upon completion updates `self.image` to reflect the returned image
    ///
    /// Once the image has loaded from the URL it will be displayed at the same size as the placeholderImage (or the provided size)
    /// so make sure that placeholderImage is the same size as the returned image. Not doing so causes strange frame behaviour
    /// in `UITableViewCell` subclasses
    ///
    /// - parameter imageURL:        The URL to load the image from
    /// - parameter withPlaceholder: The image to use as a placeholder for the loading image (Optional)
    /// - parameter imageSize:       The final image size that will be returned from the URL if known
    /// - parameter animated:        Whether the loading image should animate in when retrieved
    /// - parameter completion:      A closure which will be called upon the completed load of the image.
    func set(imageURL: URL?, withPlaceholder: UIImage?, imageSize: CGSize = CGSize.zero, animated: Bool = false, completion: ImageViewSetImageURLCompletion?) {
        
        if let imageURL = imageURL {
            set(imageURLS: [imageURL], withPlaceholder: withPlaceholder, imageSize: imageSize, animated: animated, completion: completion)
        } else {
            set(imageURLS: nil, withPlaceholder: withPlaceholder, imageSize: imageSize, animated: animated, completion: completion)
        }
    }
    
    /// Loads the images in order from an array of URLs replacing the image of the UIImageView with a recursively higher quality image
    ///
    /// - parameter imageURLS:       The array of URLs to load into the UIImageView
    /// - parameter withPlaceholder: The image to use as a placeholder for the loading image (Optional)
    /// - parameter imageSize:       The size of the final image which will be loaded from the URL
    /// - parameter animated:        Whether the loading image should animate in when retrieved
    /// - parameter callCompletionForIntermediaryLoads: Whether `completion` should be called for intermediary image loads
    /// - parameter completion:      A closure which will be called upon the completed load of the image.
    func set(imageURLS: [URL]?, withPlaceholder: UIImage?, imageSize: CGSize = CGSize.zero, animated: Bool = false, callCompletionForIntermediaryLoads: Bool = false, completion: ImageViewSetImageURLCompletion?) {
        
        finalSize = imageSize
        cancelCurrentRequestOperations()
        self.completion = completion
        
        image = withPlaceholder
        self.imageURLS = imageURLS
        showingPlaceholder = true
        
        requests = imageURLS?.map({
            
            return ImageController.shared.loadImage(fromURL: $0, completion: { [weak self] (image, error, request) in
                
                guard let welf = self else { return }
                
                // Only update the image if the request is still in the queue (Hasn't been cancelled)
                if let requests = welf.requests, requests.contains(where: { $0.urlRequest == request?.urlRequest }), let replacementImage = image {
                    
                    // Replace the current image if we're showing the placeholder or the returned image is larger than the current one
                    var replaceImage = welf.showingPlaceholder && image != nil
                    
                    // Check if the returned image is larger
                    if let currentImage = welf.image, !replaceImage {
                        replaceImage = replacementImage.size.width > currentImage.size.width || replacementImage.size.height > currentImage.size.height
                    }
                    
                    if replaceImage {
                        
                        welf.showingPlaceholder = false
                        welf.image = replacementImage
                        welf.setNeedsUpdateConstraints()
                        welf.setNeedsLayout()
                        
                        // Animate the change
                        if animated {
                            let transition = CATransition()
                            transition.type = CATransitionType.fade
                            transition.duration = 0.25
                        }
                    }
                    
                    // Cancel lower resolution requests if there are any!
                    if let requestIndex = welf.requests?.firstIndex(where: { $0.urlRequest == request?.urlRequest }), let requests = welf.requests {
                        
                        requests.enumerated().forEach({ (index, request) in
                            
                            if index < requestIndex {
                                
                                ImageController.shared.cancel(imageRequest: request)
                                welf.requests?.remove(at: index)
                            }
                        })
                        
                        // Remove this image request from the queued requests, recalculate index,
                        // because above code may have broken the ordering!
                        if let index = welf.requests?.firstIndex(where: { $0.urlRequest == request?.urlRequest }) {
                            welf.requests?.remove(at: index)
                        }
                    }
                }
                
                // If no remaining requests, call the completion
                if welf.requests?.count == 0 {
                    
                    welf.cancelCurrentRequestOperations(callingCompletion: false)
                    welf.imageURLS = nil
                    welf.completion?(image, error)
                    welf.completion = nil
                    
                } else if callCompletionForIntermediaryLoads {
                    
                    welf.completion?(image, error)
                }
            })
        })
    }
    
    private func cancelCurrentRequestOperations(callingCompletion: Bool = true) {
        if callingCompletion {
            completion?(nil, ImageViewError.cancelledDueToNewUrl)
        }
        requests?.forEach({ (request) in
            ImageController.shared.cancel(imageRequest: request)
        })
        requests = nil
    }
}

enum ImageViewError: Error {
    case cancelledDueToNewUrl
}

