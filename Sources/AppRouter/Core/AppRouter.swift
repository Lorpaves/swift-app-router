//
//  AppRouter.swift
//  swift-app-router
//
//  Created by Lorpaves on 2025/4/19.
//

#if canImport(UIKit)
import Mutex
import UIKit

public final class AppRouter {
    private let routes: Mutex<[String: RouteItem<UIViewController>]> = Mutex([:])
    private let navigator: any AppNavigator = AppNavigatorImpl()
    private let interceptors: Mutex<[RouteInterceptor]> = Mutex([])
    private init() {}
    
    nonisolated(unsafe) public static let shared = AppRouter()
}

public let Router = AppRouter.shared

public extension Routable where Self == AppRouter {
    static var app: Self {
        AppRouter.shared
    }
}

extension AppRouter: Routable {
    public typealias Representable = UIViewController
    @discardableResult
    public func register(interceptor: any RouteInterceptor) -> Self {
        interceptors.withLock({ $0.append(interceptor) })
        return self
    }
    @discardableResult
    public func register(handler: any RouteHandler, context: Any? = nil) -> Self {
        let priority = self.priority(of: handler.pattern)
        let key = normalize(pattern: handler.pattern)
        routes.withLock({
            guard $0[key] == nil else {
                assertionFailure("Trying to register a route which is already exists: \"\(handler.pattern)\"")
                return
            }
            $0[key] = RouteItem(
                pattern: handler.pattern,
                priority: priority,
                context: context,
                factory: handler.factory,
                completion: handler.completion
            )
        })
        return self
    }
    private func intercept(route: any Route) async throws {
        let candidates = interceptors.withLock({ $0 }).sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
        for candidate in candidates {
            try await candidate.intercept(route)
        }
    }
    
    @discardableResult
    public func register(_ pattern: String, context: Any? = nil, factory: @escaping RepresentableFactory<Representable>, completion: (() -> Void)? = nil) -> Self {
        let priority = self.priority(of: pattern)
        let key = normalize(pattern: pattern)
        routes.withLock({
            guard $0[key] == nil else {
                assertionFailure("Trying to register a route which is already exists: \"\(pattern)\"")
                return
            }
            $0[key] = RouteItem(pattern: pattern, priority: priority, context: context, factory: factory, completion: completion)
        })
        return self
    }
    
    public func open(url: URL, context: Any? = nil, animated animate: Bool = true, completion: (() -> Void)? = nil) async throws {
        let (route, factory, _context, routeCompletion) = try parse(url: url)
        guard let (viewContorller, routeStyle) = await factory(route, context ?? _context) else { return }
        try await intercept(route: route)
        await navigator.navigate(
            viewContorller,
            from: nil,
            style: routeStyle,
            animated: animate,
            completion: { routeCompletion?(); completion?() }
        )
    }
    
    public func open(url: URL, context: Any? = nil, animated animate: Bool = true, completion: (() -> Void)? = nil) throws {
        let (route, factory, _context, routeCompletion) = try parse(url: url)
        guard let (viewContorller, routeStyle) = factory(route, context ?? _context) else { return }
        Task { @RouteActor [weak self] in
            guard let self else { return }
            try await self.intercept(route: route)
            await MainActor.run {
                self.navigator.navigate(
                    viewContorller,
                    from: nil,
                    style: routeStyle,
                    animated: animate,
                    completion: { routeCompletion?(); completion?() }
                )
            }
        }
    }
    
    private nonisolated func priority(of pattern: String) -> Int {
        let parts = pattern
            .replacingOccurrences(of: "://", with: "/")
            .split(separator: "/")
        
        var score = 0
        for part in parts {
            switch part.first {
            case "*": score += 0 // 通配符最低
            case ":": score += 1 // 动态段
            default: score += 2 // 静态段
            }
        }
        return score * 10 + parts.count // 段数作微调
    }
    
    /// 忽略大小写、去掉 scheme 与尾部 /
    private nonisolated func normalize(pattern: String) -> String {
        var p = pattern.lowercased()
        if p.hasSuffix("/") { p.removeLast() }
        if let range = p.range(of: "://") { p.removeSubrange(...range.upperBound) }
        return p
    }
}

extension AppRouter: RouteParser {
    nonisolated func parse(url: URL) throws -> (route: any Route, factory: RepresentableFactory<Representable>, context: Any?, completion: (() -> Void)?) {
        guard let host = url.host else { throw RouteError.invalidURL(url.absoluteString) }
        let path = "/\(host)\(url.path)"
        let candidates = routes.withLock({ $0.values }).sorted(by: { $0.priority > $1.priority })
        
        // 按优先级排序后再匹配
        for candidate in candidates {
            if let params = candidate.pattern.match(path: path, url: url) {
                return (RouteImpl(url: url, path: path, parameters: params), candidate.factory, candidate.context, candidate.completion)
            }
        }
        throw RouteError.urlNotFound(url.absoluteString)
    }
}

#endif
