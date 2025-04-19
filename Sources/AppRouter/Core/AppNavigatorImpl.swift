//
//  AppNavigatorImpl.swift
//  swift-app-router
//
//  Created by Lorpaves on 2025/4/19.
//

import UIKit

struct AppNavigatorImpl: AppNavigator {
    typealias Representable = UIViewController
    func navigate(
        _ viewController: UIViewController,
        from fromController: UIViewController? = nil,
        style: RouteStyle,
        animated animate: Bool = true,
        completion: (() -> Void)?
    ) {
        switch style {
        case .push:
            self.push(viewController, from: fromController, animated: animate, completion: completion)
        case .modal:
            self.present(viewController, from: fromController, animated: animate, completion: completion)
        case .asWindowRoot:
            self.setWindowRootViewController(viewController, completion: completion)
        case .asWindowNavRoot:
            self.setWindowRootNavController(viewController, completion: completion)
        case .navigateToTarget:
            self.popTo(type(of: viewController), animated: animate, completion: completion)
        case .dismissModalsAndPush:
            self.dismissModalsAndPush(viewController, animated: animate, completion: completion)
        }
    }
    
    func navigate(
        _ viewController: UIViewController,
        from fromController: UIViewController? = nil,
        style: RouteStyle,
        animated animate: Bool = true,
        completion: (() -> Void)?
    ) async {
        await MainActor.run {
            self.navigate(viewController, from: fromController, style: style, animated: animate, completion: completion)
        }
    }
}
