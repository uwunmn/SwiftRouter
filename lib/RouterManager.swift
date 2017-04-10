//
//  RouterManager.swift
//  Pods
//
//  Created by Xiaohui on 16/5/25.
//
//

import Foundation

public class RouterManager {
 
    public static let sharedInstance = RouterManager()
    fileprivate let defaultScheme = "RouterManager"
    fileprivate let defaultHost = "RouterManager"
    
    fileprivate let defaultRouter: Router
    fileprivate var routers = [Router]()
    
    public func map(pattern: String, routable: Routable.Type) {
        self.defaultRouter.map(pattern: pattern, routable: routable)
    }
    
    public func handle(path: String, data: [String: Any]? = nil) -> Routable? {
        let urlString = "\(defaultScheme)://\(defaultHost)\(path)"
        return self.handle(entity: RouteEntity(urlString: urlString, data: data))
    }
    
    public func register(router: Router) {
        routers.append(router)
    }
    
    public func unregister(router: Router) {
        routers = routers.filter { (r) -> Bool in
            return r == router
        }
    }
    
    public func handle(string urlString: String, data: [String: AnyObject]? = nil, mustMatchKeyPoint: Bool = false) -> Routable? {
        return self.handle(entity: RouteEntity(urlString: urlString, data: data), mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func handle(url: URL, data: [String: AnyObject]? = nil, mustMatchKeyPoint: Bool = false) -> Routable? {
        return self.handle(entity: RouteEntity(url: url, data: data), mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func handle(entity: RouteEntity, mustMatchKeyPoint: Bool = false) -> Routable? {
        for router in routers {
            if mustMatchKeyPoint && !router.isKeyPoint {
                continue
            }
            if let routable = router.handle(entity: entity) {
                return routable
            }
        }
        return nil
    }
    
    public func match(string urlString: String, mustMatchKeyPoint: Bool = false) -> Bool {
        return match(entity: RouteEntity(urlString: urlString), mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func match(url: URL, mustMatchKeyPoint: Bool = false) -> Bool {
        return match(entity: RouteEntity(url: url), mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func match(entity: RouteEntity, mustMatchKeyPoint: Bool = false) -> Bool {
        for router in routers {
            if mustMatchKeyPoint && !router.isKeyPoint {
                continue
            }
            if router.match(entity: entity) {
                return true
            }
        }
        return false
    }
    
    fileprivate init() {
        self.defaultRouter = Router(scheme: defaultScheme, hostPattern: defaultHost)
        self.register(router: defaultRouter)
    }
}
