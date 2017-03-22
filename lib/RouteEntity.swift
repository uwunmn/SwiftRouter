//
//  RouteEntity.swift
//  Pods
//
//  Created by Xiaohui on 16/5/26.
//
//

import Foundation

public final class RouteEntity {
    
    public let data: [String: AnyObject]
    public var url: NSURL?
    
    public var scheme: String {
        if let url = self.url, scheme = url.scheme {
            return  scheme
        }
        return ""
    }
    
    public var host: String {
        if let url = self.url, host = url.host {
            return host
        }
        return ""
    }
    
    public var path: String {
        if let url = self.url, path = url.path where !path.isEmpty {
            return path
        }
        return "/"
    }
    
    convenience public init(urlString: String, data: [String: AnyObject]? = nil) {
        self.init(url: urlString.URLValue, data: data)
    }
    
    convenience public init(scheme: String, host: String, path: String, data: [String: AnyObject]? = nil) {
        self.init(url: NSURL(scheme: scheme, host: host, path: path), data: data)
    }
    
    public init(url: NSURL?, data: [String: AnyObject]? = nil) {
        var newData = data ?? [String: AnyObject]()
        if let url = url, queryMap: [String: String] = url.queryParameters {
            for (key, value) in queryMap {
                newData[key] = value
            }
        }
        self.url = url
        self.data = newData
    }
    
    public func isValid() -> Bool {
        return self.url != nil
            && !self.scheme.isEmpty
            && !self.host.isEmpty
            && !self.path.isEmpty
    }
}

public protocol URLConvertible {
    var URLValue: NSURL? { get }
    var URLStringValue: String { get }
    
    var queryParameters: [String: String] { get }
    
    @available(iOS 8, *)
    var queryItems: [NSURLQueryItem]? { get }
}

extension URLConvertible {
    public var queryParameters: [String: String] {
        var parameters = [String: String]()
        self.URLValue?.query?.componentsSeparatedByString("&").forEach {
            let keyAndValue = $0.componentsSeparatedByString("=")
            if keyAndValue.count == 2 {
                let key = keyAndValue[0]
                let value = keyAndValue[1].stringByReplacingOccurrencesOfString("+", withString: " ")
                    .stringByRemovingPercentEncoding ?? keyAndValue[1]
                parameters[key] = value
            }
        }
        return parameters
    }
    
    @available(iOS 8, *)
    public var queryItems: [NSURLQueryItem]? {
        return NSURLComponents(string: self.URLStringValue)?.queryItems
    }
}

extension String: URLConvertible {
    public var URLValue: NSURL? {
        if let URL = NSURL(string: self) {
            return URL
        }
        let set = NSMutableCharacterSet()
        set.formUnionWithCharacterSet(.URLHostAllowedCharacterSet())
        set.formUnionWithCharacterSet(.URLPathAllowedCharacterSet())
        set.formUnionWithCharacterSet(.URLQueryAllowedCharacterSet())
        set.formUnionWithCharacterSet(.URLFragmentAllowedCharacterSet())
        return self.stringByAddingPercentEncodingWithAllowedCharacters(set).flatMap { NSURL(string: $0) }
    }
    
    public var URLStringValue: String {
        return self
    }
}

extension NSURL: URLConvertible {
    public var URLValue: NSURL? {
        return self
    }
    
    public var URLStringValue: String {
        return self.absoluteString ?? ""
    }
}
