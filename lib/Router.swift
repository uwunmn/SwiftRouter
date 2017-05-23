//
//  Router.swift
//  Pods
//
//  Created by Xiaohui on 16/5/26.
//
//

import Foundation

public class Router: Equatable {
    
    public let scheme: String
    public let hostPattern: String
    private var rules = [RouteRule]()
    private(set) var isKeyPoint: Bool
    
    public init(scheme: String, hostPattern: String, isKeyPoint: Bool = false) {
        self.scheme = scheme
        self.hostPattern = hostPattern
        self.isKeyPoint = isKeyPoint
    }
    
    public func add(rule: RouteRule) {
        self.rules.append(rule)
    }
    
    public func add(pattern: String, handler: @escaping RouteHandler) {
        self.add(rule: RouteRule(pattern: pattern, handler: handler))
    }
    
    public func add(patterns: [String], handler: @escaping RouteHandler) {
        for pattern in patterns {
            self.add(pattern: pattern, handler: handler)
        }
    }
    
    public func handle(urlString: String, data: [String: Any]? = nil) -> Bool {
        return self.handle(entity: RouteEntity(urlString: urlString, data: data))
    }
    
    public func handle(url: URL, data: [String: Any]? = nil) -> Bool {
        return self.handle(entity: RouteEntity(url: url, data: data))
    }
    
    public func handle(entity: RouteEntity) -> Bool {
        if let handler = self.matchOne(entity: entity) {
            handler(entity)
            return true
        }
        return false
    }
    
    public func match(entity: RouteEntity) -> Bool {
        return self.matchOne(entity: entity) != nil
    }
    
    private func matchOne(entity: RouteEntity) -> RouteHandler? {
        if entity.isValid && self.accept(url: entity.url) {
            for rule in self.rules {
                if rule.match(path: entity.path) {
                    return rule.handler
                }
            }
        }
        return nil
    }
    
    public func accept(url: URL?) -> Bool {
        if let url = url,
            let scheme = url.scheme,
            let host = url.host {
            return self.scheme == scheme
                && self.match(pattern: self.hostPattern, text: host)
        }
        
        return false
    }
    
    private func match(pattern: String, text: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: text)
    }
}

public func ==(lhs: Router, rhs: Router) -> Bool {
    return lhs.scheme == rhs.scheme && lhs.hostPattern == rhs.hostPattern
}
