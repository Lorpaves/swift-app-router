//
//  RouteItem.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

import Foundation

struct RouteItem<R>: @unchecked Sendable {
    let pattern: RoutePattern
    let factory: RepresentableFactory<R>
    let priority: Int
    let context: Any?
    let completion: (() -> Void)?
    init(pattern: String, priority: Int, context: Any?, factory: @escaping RepresentableFactory<R>, completion: (() -> Void)?) {
        self.pattern = RoutePattern(pattern)
        self.priority = priority
        self.context = context
        self.factory = factory
        self.completion = completion
    }
    
}
