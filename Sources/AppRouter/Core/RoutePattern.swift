//
//  RoutePattern.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

import Foundation

/// 把「:name」转捕获组，把「*」转尾部通配；
/// match(path:url:) 成功时返回 [参数:值]，失败返回 nil
struct RoutePattern {
    let raw: String
    
    let regex: NSRegularExpression
    private let keys: [String]         // 捕获组对应的参数名，顺序保持一致
    
    init(_ pattern: String) {
        raw = pattern
        
        // 1. 去掉 scheme://
        let noScheme = pattern.components(separatedBy: "://").last ?? pattern
        // 2. 去掉首尾 /
        let clean = noScheme.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        // 3. 拆段
        let parts = clean.split(separator: "/").map(String.init)

        var keys: [String] = []
        var regexString = "^"

        for part in parts {
            if part == "*" {
                keys.append("*")
                regexString += "/(.*)"
                break
            } else if part.first == ":" {
                keys.append(String(part.dropFirst()))
                regexString += "/([^/]+)"
            } else {
                regexString += "/" + NSRegularExpression.escapedPattern(for: part)
            }
        }
        regexString += "$"

        self.keys = keys
        self.regex = try! NSRegularExpression(pattern: regexString, options: [])
    }
    
    /// - Parameters:
    ///   - path: 形如 `/user/123` 的路径（不含 query）
    ///   - url: 完整 URL，用来取 queryItems
    /// - Returns: 路径参数 + query 合并字典
    func match(path: String, url: URL) -> [String: String]? {
        guard let m = regex.firstMatch(
            in: path,
            range: NSRange(path.utf16.startIndex..., in: path)
        ) else {
            return nil
        }
        
        var params: [String: String] = [:]
        // 提取捕获组
        for (idx, key) in keys.enumerated() {
            let range = m.range(at: idx + 1)
            guard range.location != NSNotFound,
                  let swiftRange = Range(range, in: path) else { continue }
            params[key] = String(path[swiftRange])
        }
        // 合并 query
        if let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in items { params[item.name] = item.value ?? "" }
        }
        return params
    }
}
