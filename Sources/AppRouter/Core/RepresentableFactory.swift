//
//  RepresentableFactory.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

import Foundation

public typealias RepresentableFactory<R> = @MainActor (_ route: any Route, _ context: Any?) -> (r: R, style: RouteStyle)?
