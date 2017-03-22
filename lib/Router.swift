//
//  Router.swift
//  Pods
//
//  Created by Xiaohui on 16/5/26.
//
//

import Foundation

public class Router: Equatable {
    
    public typealias Interceptor = (Routable?) -> Void
    
    public let scheme: String
    public let hostPattern: String
    private var routerMap = [String: Routable.Type]()
    private var interceptor: Interceptor?
    private(set) var isKeyPoint: Bool

    public init(scheme: String, hostPattern: String, isKeyPoint: Bool = false) {
        self.scheme = scheme
        self.hostPattern = hostPattern
        self.isKeyPoint = isKeyPoint
    }
    
    public func setInterceptor(interceptor: Interceptor) {
        self.interceptor = interceptor
    }
    
    public func map(pattern: String, routable: Routable.Type) {
        routerMap[pattern] = routable
    }
    
    public func handle(urlString urlString: String, data: [String: AnyObject]? = nil) ->  Routable? {
        return handle(RouteEntity(urlString: urlString, data: data))
    }
    
    public func handle(url url: NSURL, data: [String: AnyObject]? = nil) -> Routable? {
        return handle(RouteEntity(url: url, data: data))
    }
    
    public func handle(routeEntity: RouteEntity) -> Routable? {
        if let routableType = matchOne(routeEntity) {
            let routable = routableType.init()
            routable.handleRouteEntity(routeEntity)
            if let interceptor = self.interceptor {
                interceptor(routable)
            }
            return routable
        }
        return nil
    }
    
    public func match(routeEntity: RouteEntity) -> Bool {
        return self.matchOne(routeEntity) != nil
    }
    
    private func matchOne(routeEntity: RouteEntity) -> Routable.Type? {
        if acceptEntity(routeEntity) {
            for (pattern, routable) in routerMap {
                if match(pattern, text: routeEntity.path) {
                    return routable
                }
            }
        }
        return nil
    }
    
    private func acceptEntity(routeEntity: RouteEntity) -> Bool {
        return routeEntity.isValid()
            && self.scheme == routeEntity.scheme
            && match(self.hostPattern, text: routeEntity.host)
    }
    
    private func match(pattern: String, text: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluateWithObject(text)
    }
}

public func ==(lhs: Router, rhs: Router) -> Bool {
    return lhs.scheme == rhs.scheme && lhs.hostPattern == rhs.hostPattern
}
