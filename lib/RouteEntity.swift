//
//  RouteEntity.swift
//  Pods
//
//  Created by Xiaohui on 16/5/26.
//
//

import Foundation

public class RouteEntity {
    public let data: NSDictionary
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
    
    convenience public init(urlString: String, data: [String : Any]? = nil) {
        self.init(url: urlString.URLValue, data: data)
    }
    
    public init(url: URL?, data: [String : Any]? = nil) {
        var newData = data ?? [String : Any]()
        if let queryMap = url?.queryParameters  {
            for (key, value) in queryMap {
                newData[key.hump()] = value
            }
        }
        self.url = url
        self.data = newData as NSDictionary
        self.data.humpAccessAble = true
    }
}

public protocol URLConvertibleProtocol {
    var URLValue: URL? { get }
    var URLStringValue: String { get }
    var queryParameters: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
}

extension URLConvertibleProtocol {
    public var queryParameters: [String: String] {
        var parameters = [String: String]()
        queryItems?.forEach {
            if let value = $0.value?.removingPercentEncoding {
                parameters[$0.name] = value
            }
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

public protocol HumpKeyAccessable {
    subscript(key: HumpAble) -> Any? { get set }
}

public protocol HumpAble{
    func hump() -> String
}

extension String: HumpAble{
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    public func hump()-> String {
        return first.lowercased() + String(characters.dropFirst())
    }
}
fileprivate struct AssociateKes {
    static var associateKeyHumpAccess = "NSDictionary.humpAccessAble"
}
extension NSDictionary{
    var humpAccessAble: Bool{
        get{
            return (objc_getAssociatedObject(self, &AssociateKes.associateKeyHumpAccess) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self,  &AssociateKes.associateKeyHumpAccess, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
extension NSDictionary:HumpKeyAccessable{
    public subscript(key: HumpAble) -> Any? {
        get {
            if self.humpAccessAble{
                return self.object(forKey:key.hump())
            }
            return self.object(forKey:key)
        }
        set {
            if let key = key as? String{
                self.setValue(newValue, forKey: key)
            }
            
        }
    }
}
