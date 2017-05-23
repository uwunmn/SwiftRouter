//
//  RouteRule.swift
//  Pods
//
//  Created by Xiaohui on 2017/5/18.
//
//

import Foundation

public typealias RouteHandler = (RouteEntity) -> Void

public class RouteRule {
    
    var pattern: String
    
    var handler: RouteHandler
    
    init(pattern: String, handler: @escaping RouteHandler) {
        self.pattern = pattern
        self.handler = handler
    }
    
    public func match(path: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", self.pattern).evaluate(with: path)
    }
}
