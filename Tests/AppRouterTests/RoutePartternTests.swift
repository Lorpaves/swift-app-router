@testable import AppRouter
import Foundation
import Testing

struct RoutePartternTests {
    // MARK: - 静态路径

    @Test func testStatic() async throws {
        let p = RoutePattern("app://settings/profile")
        let url = URL(string: "app://settings/profile")!
        let path = "/settings/profile"
        #expect(p.match(path: path, url: url) != nil)
    }

    // MARK: - :参数段

    @Test func testDynamicSegment() async throws {
        let p = RoutePattern("app://user/:id")
        let url = URL(string: "app://user/123")!
        let path = "/user/123"

        let params = p.match(path: path, url: url)
        #expect(params?["id"] == "123")
    }

    // MARK: - 通配 *

    @Test func testWildcard() {
        let p = RoutePattern("app://docs/*")
        let url = URL(string: "app://docs/swift/optionals")!
        let path = "/docs/swift/optionals"

        let params = p.match(path: path, url: url)
        #expect(params?["*"] == "swift/optionals")
    }

    // MARK: - Query 合并

    func testQueryMerge() {
        let p = RoutePattern("app://search/:keyword")
        let url = URL(string: "app://search/Swift?source=home")!
        let path = "/search/Swift"

        let params = p.match(path: path, url: url)
        #expect(params?["keyword"] == "Swift")
        #expect(params?["source"] == "home")
    }

    // MARK: - 不匹配

    func testNotMatch() {
        let p = RoutePattern("app://user/:id")
        let url = URL(string: "app://profile/123")!
        let path = "/profile/123"

        #expect(p.match(path: path, url: url) != nil)
    }
}
