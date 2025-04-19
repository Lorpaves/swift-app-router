//
//  RouteError.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

import Foundation

public enum RouteError: Error {
    case invalidURL(String)
    case urlNotFound(String)
}

extension RouteError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .urlNotFound(let url):
            return "URL not found: \(url)"
        }
    }
}
