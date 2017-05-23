//
//  RouteEntity.swift
//  Pods
//
//  Created by Xiaohui on 16/5/26.
//
//

import Foundation

public class RouteEntity {
    
    public let data: [String: Any]
    public var url: URL?
    
    public var scheme: String {
        if let url = self.url, let scheme = url.scheme {
            return scheme
        }
        return ""
    }
    
    public var host: String {
        if let url = self.url, let host = url.host {
            return host
        }
        return ""
    }
    
    public var path: String {
        if let url = self.url, !url.path.isEmpty {
            return url.path
        }
        return "/"
    }
    
    public var isValid: Bool {
        return self.url != nil
            && !self.scheme.isEmpty
            && !self.host.isEmpty
            && !self.path.isEmpty
    }
    
    convenience public init(urlString: String, data: [String: Any]? = nil) {
        self.init(url: urlString.URLValue, data: data)
    }
    
    public init(url: URL?, data: [String: Any]? = nil) {
        var newData = data ?? [String: Any]()
        if let queryMap = url?.queryParameters  {
            for (key, value) in queryMap {
                newData[key] = value
            }
        }
        self.url = url
        self.data = newData
    }
}

protocol URLConvertibleProtocol {
    var URLValue: URL? { get }
    var URLStringValue: String { get }
    var queryParameters: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
}

extension URLConvertibleProtocol {
    public var queryParameters: [String: String] {
        var parameters = [String: String]()
        URLComponents(string: self.URLStringValue)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        return parameters
    }
    
    public var queryItems: [URLQueryItem]? {
        return URLComponents(string: self.URLStringValue)?.queryItems
    }
}

extension String: URLConvertibleProtocol {
    public var URLValue: URL? {
        if let URL = URL(string: self) {
            return URL
        }
        let set = CharacterSet()
            .union(.urlHostAllowed)
            .union(.urlPathAllowed)
            .union(.urlQueryAllowed)
            .union(.urlFragmentAllowed)
        
        return self.addingPercentEncoding(withAllowedCharacters: set).flatMap { URL(string: $0) }
    }
    
    public var URLStringValue: String {
        return self
    }
}

extension URL: URLConvertibleProtocol {
    public var URLValue: URL? {
        return self
    }
    
    public var URLStringValue: String {
        return self.absoluteString
    }
}
