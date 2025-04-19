//
//  RouteParser.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

import Foundation

protocol RouteParser {
    associatedtype Representable
    func parse(url: URL) throws -> (route: any Route, factory: RepresentableFactory<Representable>, context: Any?, completion: (() -> Void)?)
}

extension RouteParser {
    func parse(urlString: String) throws -> (route: any Route, factory: RepresentableFactory<Representable>, context: Any?, completion: (() -> Void)?) {
        guard let url = URL(string: urlString) else {
            throw RouteError.invalidURL(urlString)
        }
        return try parse(url: url)
    }
}
