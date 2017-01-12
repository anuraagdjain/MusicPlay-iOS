//
//  UIImageView+AFNetworking.swift
//
//  Created by Pham Hoang Le on 23/2/15.
//  Copyright (c) 2015 Pham Hoang Le. All rights reserved.
//

import UIKit

@objc public protocol AFImageCacheProtocol:class{
    func cachedImageForRequest(request:NSURLRequest) -> UIImage?
    func cacheImage(image:UIImage, forRequest request:NSURLRequest);
}

extension UIImageView {
    private struct AssociatedKeys {
        static var SharedImageCache = "SharedImageCache"
        static var RequestImageOperation = "RequestImageOperation"
        static var URLRequestImage = "UrlRequestImage"
    }
    
    public class func setSharedImageCache(cache:AFImageCacheProtocol?) {
//        objc_setAssociatedObject(self, &AssociatedKeys.SharedImageCache, cache, UInt(OBJC_ASSOCIATION_RETAIN))
        objc_setAssociatedObject(self, &AssociatedKeys.SharedImageCache, cache, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

    }
    
    public class func sharedImageCache() -> AFImageCacheProtocol {
        struct Static {
            static var token = 0
            static var defaultImageCache:AFImageCache?
        }
        Static.defaultImageCache = AFImageCache()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: OperationQueue.main) { (NSNotification) -> Void in
            Static.defaultImageCache!.removeAllObjects()
        }
        return objc_getAssociatedObject(self, &AssociatedKeys.SharedImageCache) as? AFImageCacheProtocol ?? Static.defaultImageCache!
    }
    
    private class func af_sharedImageRequestOperationQueue() -> OperationQueue {
        struct Static {
            static var token = 0
            static var queue:OperationQueue?
        }
        Static.queue = OperationQueue()
        Static.queue!.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        
        
        return Static.queue!
    }
    
    private var af_requestImageOperation:(operation:Operation?, request: NSURLRequest?) {
        get {
            let operation:Operation? = objc_getAssociatedObject(self, &AssociatedKeys.RequestImageOperation) as? Operation
            let request:NSURLRequest? = objc_getAssociatedObject(self, &AssociatedKeys.URLRequestImage) as? NSURLRequest
            return (operation, request)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.RequestImageOperation, newValue.operation, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

//            objc_setAssociatedObject(self, &AssociatedKeys.RequestImageOperation, newValue.operation, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            objc_setAssociatedObject(self, &AssociatedKeys.URLRequestImage, newValue.request, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

//            objc_setAssociatedObject(self, &AssociatedKeys.URLRequestImage, newValue.request, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    public func setImageWithUrl(url:NSURL, placeHolderImage:UIImage? = nil) {
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        self.setImageWithUrlRequest(request: request, placeHolderImage: placeHolderImage, success: nil, failure: nil)
    }
    
    public func setImageWithUrlRequest(request:NSURLRequest, placeHolderImage:UIImage? = nil,
		success:((_ request:NSURLRequest?, _ response:URLResponse?, _ image:UIImage, _ fromCache:Bool) -> Void)?,
        failure:((_ request:NSURLRequest?, _ response:URLResponse?, _ error:NSError) -> Void)?)
    {
        self.cancelImageRequestOperation()
        
        if let cachedImage = UIImageView.sharedImageCache().cachedImageForRequest(request: request) {
            if success != nil {
				success!(nil, nil, cachedImage, true)
            }
            else {
                self.image = cachedImage
            }
            
            return
        }
        
        if placeHolderImage != nil {
            self.image = placeHolderImage
        }
        
        self.af_requestImageOperation = (BlockOperation(block: { () -> Void in
            var response:URLResponse?
            var error:NSError?
            do{
            let data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
              
            DispatchQueue.main.async(execute: { () -> Void in
                
                if request.url! == self.af_requestImageOperation.request?.url {
                    let image:UIImage? = (UIImage(data: data))
                    if image != nil {
                        if success != nil {
							success!(request, response, image!, false)
                        }
                        else {
                            self.image = image!
                        }
                        UIImageView.sharedImageCache().cacheImage(image: image!, forRequest: request)
                    }
                    else {
                        if failure != nil {
                            failure!(request, response, error!)
                        }
                    }
                    
                    self.af_requestImageOperation = (nil, nil)
                }
            })
            }
            catch{
                
            }
        }), request)
    
    
        UIImageView.af_sharedImageRequestOperationQueue().addOperation(self.af_requestImageOperation.operation!)
    }
    
    private func cancelImageRequestOperation() {
        self.af_requestImageOperation.operation?.cancel()
        self.af_requestImageOperation = (nil, nil)
    }
}

func AFImageCacheKeyFromURLRequest(request:NSURLRequest) -> String {
    return request.url!.absoluteString
}

class AFImageCache: NSCache<AnyObject, AnyObject>, AFImageCacheProtocol {
    func cachedImageForRequest(request: NSURLRequest) -> UIImage? {
        switch request.cachePolicy {
        case NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
        NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData:
            return nil
        default:
            break
        }
        
        return self.object(forKey: AFImageCacheKeyFromURLRequest(request: request) as AnyObject) as? UIImage
    }
    
    func cacheImage(image: UIImage, forRequest request: NSURLRequest) {
        self.setObject(image, forKey: AFImageCacheKeyFromURLRequest(request: request) as AnyObject)
    }
}

