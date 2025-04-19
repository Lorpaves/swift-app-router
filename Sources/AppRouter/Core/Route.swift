//
//  Route.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

import Foundation

/// URL 解析的Route
public protocol Route: Hashable, Sendable {
    var url: URL { get }
    var path: String { get }
    var parameters: RouteParameters { get }
}

extension Route {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteString)
        hasher.combine(parameters)
        hasher.combine(path)
    }
}

extension Route {
    public typealias RouteParameters = [String: String]
}

struct RouteImpl: Route {
    let url: URL
    let path: String
    let parameters: RouteParameters
}
