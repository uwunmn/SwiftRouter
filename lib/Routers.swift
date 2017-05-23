//
//  Routers.swift
//  Pods
//
//  Created by Xiaohui on 2017/5/18.
//
//

import Foundation


public class Routers {
    
    public static let shared = Routers()
    
    private var routers = [Router]()
    
    public func register(router: Router) {
        routers.append(router)
    }
    
    public func unregister(router: Router) {
        routers = routers.filter { (r) -> Bool in
            return r == router
        }
    }
    
    public func handle(string urlString: String, data: [String: Any]? = nil,
                       mustMatchKeyPoint: Bool = false) -> Bool {
        let entity = RouteEntity(urlString: urlString, data: data)
        return self.handle(entity: entity, mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func handle(url: URL, data: [String: Any]? = nil,
                       mustMatchKeyPoint: Bool = false) -> Bool {
        let entity = RouteEntity(url: url, data: data)
        return self.handle(entity: entity, mustMatchKeyPoint: mustMatchKeyPoint)
    }
    
    public func handle(entity: RouteEntity, mustMatchKeyPoint: Bool = false) -> Bool {
        for router in routers {
            if mustMatchKeyPoint && !router.isKeyPoint {
                continue
            }
            if router.handle(entity: entity) {
                return true
            }
        }
        return false
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
    
    private init() {
    }
}
