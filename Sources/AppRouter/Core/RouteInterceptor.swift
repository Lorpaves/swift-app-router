//
//  RouteInterceptor.swift
//  swift-app-router
//
//  Created by Lorpaves on 2025/4/19.
//

import Foundation

public struct RouteInterceptorPriority: RawRepresentable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let low = RouteInterceptorPriority(1)
    public static let medium = RouteInterceptorPriority(10)
    public static let hight = RouteInterceptorPriority(100)
    public static let extraHigh = RouteInterceptorPriority(1000)
}

/// 统一拦截接口，可抛错终止路由
public protocol RouteInterceptor {
    var priority: RouteInterceptorPriority { get }
    /// - Throws: 抛 `RouteError.cancelled` 即可打断后续流程
    @RouteActor func intercept(_ route: any Route) async throws
}

public extension RouteInterceptor {
    var priority: RouteInterceptorPriority { .medium }
}
