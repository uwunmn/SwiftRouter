//
//  TorlaxRouter.swift
//  Pods
//
//  Created by Xiaohui on 16/5/25.
//
//

import Foundation

public enum OpenMode {
    case None
    case Push
    case Present
}


public final class RouterManager {
 
    public static let sharedInstance = RouterManager()
    private let defaultScheme = "RouterManager"
    private let defaultHost = "RouterManager"
    
    private let defaultRouter: Router
    private var routers = [Router]()
    
    public func map(pattern: String, routable: Routable.Type) {
        defaultRouter.map(pattern, routable: routable)
    }
    
    public func handle(path path: String, data: [String: AnyObject]? = nil) -> Routable? {
        return handle(RouteEntity(scheme: defaultScheme, host: defaultHost, path: path, data: data))
    }
    
    public func registerRouter(router: Router) {
        routers.append(router)
    }
    
    public func unregisterRouter(router: Router) {
        routers = routers.filter { (r) -> Bool in
            return r == router
        }
    }
    
    public func handle(string urlString: String, data: [String: AnyObject]? = nil, mustMatchKeyPoint: Bool = false) -> Routable? {
        return handle(RouteEntity(urlString: urlString, data: data), mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func handle(url url: NSURL, data: [String: AnyObject]? = nil, mustMatchKeyPoint: Bool = false) -> Routable? {
        return handle(RouteEntity(url: url, data: data), mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func handle(entity: RouteEntity, mustMatchKeyPoint: Bool = false) -> Routable? {
        for router in routers {
            if mustMatchKeyPoint && !router.isKeyPoint {
                continue
            }
            if let routable = router.handle(entity) {
                return routable
            }
        }
        return nil
    }
    
    public func match(string urlString: String, mustMatchKeyPoint: Bool = false) -> Bool {
        return match(RouteEntity(urlString: urlString), mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func match(url url: NSURL, mustMatchKeyPoint: Bool = false) -> Bool {
        return match(RouteEntity(url: url), mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func match(entity: RouteEntity, mustMatchKeyPoint: Bool = false) -> Bool {
        for router in routers {
            if mustMatchKeyPoint && !router.isKeyPoint {
                continue
            }
            if router.match(entity) {
                return true
            }
        }
        return false
    }
    
    private init() {
        defaultRouter = Router(scheme: defaultScheme, hostPattern: defaultHost)
        self.registerRouter(defaultRouter)
    }
}

public let TorlaxRouter = RouterManager.sharedInstance
