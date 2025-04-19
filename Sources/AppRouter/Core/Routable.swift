//
//  Routable.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

import Mutex
import Foundation

public protocol Routable {
    associatedtype Representable
    @RouteActor func open(url: URL, context: Any?, animated animate: Bool, completion: (() -> Void)?) async throws
    @MainActor func open(url: URL, context: Any?, animated animate: Bool, completion: (() -> Void)?) throws
    func register(_ pattern: String, context: Any?, factory: @escaping RepresentableFactory<Representable>, completion: (() -> Void)?) -> Self
    func register(interceptor: any RouteInterceptor) -> Self
    func register(handler: any RouteHandler, context: Any?) -> Self
}
