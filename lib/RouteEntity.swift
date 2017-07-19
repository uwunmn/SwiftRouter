//
//  RouteEntity.swift
//  Pods
//
//  Created by Xiaohui on 16/5/26.
//
//

import Foundation


public class RouteEntity {
    public let data:CaseInsensitiveDictionary<String, Any>
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
                newData[key] = value
            }
        }
        self.url = url
        self.data = CaseInsensitiveDictionary<String, Any>.init(dictionary: newData)
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

public struct CaseInsensitiveDictionary<Key: Hashable, Value>: Collection,
    ExpressibleByDictionaryLiteral
{
    private var _data: [Key: Value] = [:]
    private var _keyMap: [String: Key] = [:]

    public typealias Element = (key: Key, value: Value)
    public typealias Index = DictionaryIndex<Key, Value>
    public var startIndex: Index {
        return _data.startIndex
    }
    public var endIndex: Index {
        return _data.endIndex
    }
    public func index(after: Index) -> Index {
        return _data.index(after: after)
    }

    public var count: Int {
        assert(_data.count == _keyMap.count, "internal keys out of sync")
        return _data.count
    }

    public var isEmpty: Bool {
        return _data.isEmpty
    }

    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (key, value) in elements {
            _keyMap["\(key)".lowercased()] = key
            _data[key] = value
        }
    }

    public init(dictionary: [Key: Value]) {
        for (key, value) in dictionary {
            _keyMap["\(key)".lowercased()] = key
            _data[key] = value
        }
    }

    public subscript (position: Index) -> Element {
        return _data[position]
    }

    public subscript (key: Key) -> Value? {
        get {
            if let realKey = _keyMap["\(key)".lowercased()] {
                return _data[realKey]
            }
            return nil
        }
        set(newValue) {
            let lowerKey = "\(key)".lowercased()
            if _keyMap[lowerKey] == nil {
                _keyMap[lowerKey] = key
            }
            _data[_keyMap[lowerKey]!] = newValue
        }
    }

    public func makeIterator() -> DictionaryIterator<Key, Value> {
        return _data.makeIterator()
    }

    public var keys: LazyMapCollection<[Key : Value], Key> {
        return _data.keys
    }
    public var values: LazyMapCollection<[Key : Value], Value> {
        return _data.values
    }
}

