//
//  Routable.swift
//  Pods
//
//  Created by Xiaohui on 16/5/26.
//
//

import Foundation

public protocol Routable: class {
    init()
    
    func handleRouteEntity(routeEnity: RouteEntity)
}
