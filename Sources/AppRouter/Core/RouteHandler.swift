//
//  RouteHandler.swift
//  swift-app-router
//
//  Created by Lorpaves on 2025/4/19.
//

import Foundation

public protocol RouteHandler {
    var pattern: String { get }
    var completion: (() -> Void)? { get }

    func factory<R>(_ route: any Route, context: Any?) -> (r: R, style: RouteStyle)
}

public extension RouteHandler {
    var completion: (() -> Void)? { nil }
}
