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
    
    public func setInterceptor(interceptor: @escaping Interceptor) {
        self.interceptor = interceptor
    }
    
    public func map(pattern: String, routable: Routable.Type) {
        self.routerMap[pattern] = routable
    }
    
    public func handle(urlString: String, data: [String: Any]? = nil) ->  Routable? {
        return self.handle(entity: RouteEntity(urlString: urlString, data: data))
    }
    
    public func handle(url: URL, data: [String: Any]? = nil) -> Routable? {
        return self.handle(entity: RouteEntity(url: url, data: data))
    }
    
    public func handle(entity: RouteEntity) -> Routable? {
        if let routableType = self.matchOne(entity: entity) {
            let routable = routableType.init()
            routable.handleRouteEntity(routeEntity: entity)
            self.interceptor?(routable)
            return routable
        }
        return nil
    }
    
    public func match(entity: RouteEntity) -> Bool {
        return self.matchOne(entity: entity) != nil
    }
    
    private func matchOne(entity: RouteEntity) -> Routable.Type? {
        if self.accept(entity: entity) {
            for (pattern, routable) in routerMap {
                if match(pattern: pattern, text: entity.path) {
                    return routable
                }
            }
        }
        return nil
    }
    
    private func accept(entity: RouteEntity) -> Bool {
        return entity.isValid()
            && self.scheme == entity.scheme
            && self.match(pattern: self.hostPattern, text: entity.host)
    }
    
    private func match(pattern: String, text: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: text)
    }
}

public func ==(lhs: Router, rhs: Router) -> Bool {
    return lhs.scheme == rhs.scheme && lhs.hostPattern == rhs.hostPattern
}
