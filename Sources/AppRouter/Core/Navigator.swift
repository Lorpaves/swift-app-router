//
//  Navigator.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

import Foundation

public protocol Navigator {
    associatedtype Representable
    func navigate(
        _ viewController: Representable,
        from fromController: Representable?,
        style: RouteStyle,
        animated animate: Bool,
        completion: (() -> Void)?
    ) async
    @MainActor func navigate(
        _ viewController: Representable,
        from fromController: Representable?,
        style: RouteStyle,
        animated animate: Bool,
        completion: (() -> Void)?
    )
}
