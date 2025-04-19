# swift-app-route

> A lightweight and flexible routing library for Swift developers.

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey)
![Swift](https://img.shields.io/badge/swift-5.9-orange)
![License](https://img.shields.io/github/license/your-username/swift-app-route)

## 🧩 Features

- ✅ Simple and intuitive route registration and matching
- 🔀 Supports wildcard and parameterized routes (`:id`, `*`)
- 🔧 Easy to integrate into existing Swift apps
- 📱 Supports iOS, macCatalyst, tvOS, watchOS, and visionOS

## 🚀 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/lorpaves/swift-app-route.git", from: "1.0.0")
]
```

## 📦 Usage

### Register Routes

```swift
import Router

Router.register("myapp://user/:id") { route, _ in
    if let userID = route.parameters["id"] {
        print("User ID: \(userID)")
        return (UserViewController(userID: userID), .modal)
    }
    return nil
}

let url = URL(string: "myapp://user/123")!
Router.open(url: url)

```

### Wildcard Match

```swift
Router.register("myapp://docs/*") { route, _ in
    print(route.parameters)
    print(route.url)
    print(route.path)
    return (DocViewController(...), .push)
}
```

### Interceptors

```swift

struct LoginInterceptor: RouteInterceptor {
    let priority = RouteInterceptorPriority.extraHigh
    
    func intercept(_ route: any Route) async throws {
        if route.path.contains("userInfo") {
            AppRouter.shared.open(".../login")
            throw MyError.notLoggedIn
        }
    }
}

Router.register(interceptor: LoginInterceptor())

```

### Integrate with UIKit


```swift
import Router

// AppDelegate
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    Task {
        print("Open url: \(url)")
        try await Router.open(url: url, completion: {
            print("Handled")
        })
    }
    return false
}

```

### Integrate with SwiftUI

```swift
import Router

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.openURL, OpenURLAction { url in
                    Task {
                        print("Open url: \(url)")
                        try await Router.open(url: url)
                    }
                    return .handled
                })
        }
    }
}

```

## 📄 Documentation

- [API Reference](./Documentation/API.md)
- [Getting Started](./Documentation/GettingStarted.md)

## ✅ Compatibility

| Platform    | Minimum Version |
|-------------|-----------------|
| iOS         | 13.0            |
| macCatalyst | 13.0            |
| tvOS        | 13.0            |
| watchOS     | 6.0             |
| visionOS    | 1.0             |

## 🙌 Contributing

We welcome contributions! Please check out the [Contributing Guide](./CONTRIBUTING.md) before opening a PR.

## 📄 License

Licensed under the MIT License. See [LICENSE](./LICENSE) for details.

---
