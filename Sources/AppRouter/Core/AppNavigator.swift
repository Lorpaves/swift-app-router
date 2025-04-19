//
//  AppNavigator.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//

#if canImport(UIKit)
import UIKit

public protocol AppNavigator: Navigator where Representable == UIViewController {
    @MainActor func push(
        _ viewController: UIViewController,
        from fromController: Representable?,
        animated animate: Bool,
        completion: (() -> Void)?
    )
    @MainActor func popTo<VC: UIViewController>(
        _ viewController: VC.Type,
        animated animate: Bool,
        completion: (() -> Void)?
    )
    @MainActor func popToRoot(
        from fromController: UIViewController?,
        animated animate: Bool,
        completion: (() -> Void)?
    )
    @MainActor func dismissModalsAndPush(
        _ viewController: UIViewController,
        animated animate: Bool,
        completion: (() -> Void)?
    )
    @MainActor func present(
        _ viewController: UIViewController,
        from fromController: UIViewController?,
        animated animate: Bool,
        completion: (() -> Void)?
    )
    @MainActor func setWindowRootNavController(
        _ viewController: UIViewController,
        completion: (() -> Void)?
    )
    @MainActor func setWindowRootViewController(
        _ viewController: UIViewController,
        completion: (() -> Void)?
    )
}

// MARK: - Extension
@MainActor public extension Navigator where Representable == UIViewController {
    func push(_ viewController: UIViewController, from fromController: UIViewController? = nil, animated animate: Bool = true, completion: (() -> Void)? = nil) {
        viewController.hidesBottomBarWhenPushed = true
        
        if let fromController {
            if let navController = (firstNavigationContainer(from: fromController) as? UINavigationController) ?? childNavigationController(in: fromController) {
                navController.pushViewController(viewController, animated: animate)
                navController.onCompleteAnimatedTransitoning(perform: completion)
            } else {
                pushFullBackToPresent(viewController, from: fromController, animated: animate, completion: completion)
            }
            
            return
        }
        guard let activeViewController = activeViewController else {
            NSLog("[Error] Trying to push view controller '\(viewController)' but there is no active view controller.")
            return
        }
        if activeViewController is UITabBarController {
            if let navController = topViewController()?.navigationController {
                navController.pushViewController(viewController, animated: animate)
            } else {
                pushFullBackToPresent(viewController, from: fromController, animated: animate, completion: completion)
            }
            
        } else {
            DispatchQueue.main.async {
                if let navigationController = (activeViewController as? UINavigationController) ?? (firstNavigationContainer(from: activeViewController)?.navigationController) ?? childNavigationController(in: activeViewController) {
                    navigationController.pushViewController(viewController, animated: animate)
                    navigationController.onCompleteAnimatedTransitoning(perform: completion)
                } else {
                    pushFullBackToPresent(viewController, from: fromController, animated: animate, completion: completion)
                    
                }
            }
        }
    }
    
    private func pushFullBackToPresent(_ viewController: UIViewController, from fromController: UIViewController? = nil, animated animate: Bool = true, completion: (() -> Void)? = nil) {
        
        NSLog("[Warning] Trying to push view controller '\(viewController)' but not found navigation controller, fallback to modal style.")
        present(viewController, from: fromController, animated: animate, completion: completion)
    }
    
    func popTo<VC: UIViewController>(_ viewController: VC.Type, animated animate: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigationController = topViewController()?.navigationController else {
            NSLog("[Error] Trying to pop to view controller '\(VC.self)' but there is no navigation controller.")
            return
        }
        
        guard let targetViewController = navigationController.viewControllers.last(where: { $0.isKind(of: VC.self) }) else {
            navigationController.popViewController(animated: animate)
            navigationController.onCompleteAnimatedTransitoning(perform: completion)
            return
        }
        
        DispatchQueue.main.async {
            navigationController.popToViewController(targetViewController, animated: animate)
            navigationController.onCompleteAnimatedTransitoning(perform: completion)
        }
    }
    
    func popToRoot(from fromController: UIViewController? = nil, animated animate: Bool = true, completion: (() -> Void)? = nil) {
        if let fromController {
            
            let navController = (firstNavigationContainer(from: fromController) as? UINavigationController) ?? childNavigationController(in: fromController)
            
            navController?.popToRootViewController(animated: animate)
            navController?.onCompleteAnimatedTransitoning(perform: completion)
            return
        }
        
        guard let navigationController = topViewController()?.navigationController else {
            NSLog("[Error] Trying to pop to root view controller in navigation stack, but there is no navigation controller.")
            return
        }
        navigationController.popToRootViewController(animated: animate)
        navigationController.onCompleteAnimatedTransitoning(perform: completion)
    }
    
    func dismissModalsAndPush(_ viewController: UIViewController, animated animate: Bool = true, completion: (() -> Void)? = nil) {
        if let visibleViewController = topViewController(), visibleViewController.presentingViewController != nil {
            visibleViewController.dismiss(animated: animate) {
                push(viewController, animated: animate, completion: completion)
            }
        } else {
            push(viewController, animated: animate, completion: completion)
        }
    }
    
    func present(_ viewController: UIViewController, from fromController: UIViewController? = nil, animated animate: Bool = true, completion: (() -> Void)? = nil) {
        if let fromController {
            fromController.present(viewController, animated: animate, completion: completion)
            return
        }
        guard let activeViewController = activeViewController else {
            NSLog("[Error] Trying to present view controller '\(viewController)' without active view controller.")
            return
        }
        DispatchQueue.main.async {
            activeViewController.present(viewController, animated: animate, completion: completion)
        }
    }
    
    func setWindowRootNavController(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        let keyWindow = self.keyWindow
        if viewController is UINavigationController {
            keyWindow?.rootViewController = viewController
        } else {
            keyWindow?.rootViewController = UINavigationController(rootViewController: viewController)
        }
        completion?()
    }
    
    func setWindowRootViewController(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        keyWindow?.rootViewController = viewController
        completion?()
    }
}

@MainActor public extension Navigator where Representable == UIViewController {
    var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.compactMap({ scene in
                if let windowScene = scene as? UIWindowScene {
                    if #available(iOS 15.0, *) {
                        return windowScene.keyWindow
                    } else {
                        return windowScene.windows.first(where: { $0.isKeyWindow })
                    }
                }
                return nil
            }).first
        } else {
            return UIApplication.shared.delegate?.window ?? UIApplication.shared.keyWindow
        }
    }
    
    var rootViewController: UIViewController? {
        var activeWindow: UIWindow?
        if #available(iOS 13.0, *) {
            activeWindow = UIApplication.shared.connectedScenes.compactMap({ scene in
                if let windowScene = scene as? UIWindowScene {
                    return windowScene.windows.first(where: { $0.windowLevel == .normal })
                }
                return nil
            }).first
        } else {
            activeWindow = UIApplication.shared.windows.first(where: { $0.windowLevel == .normal })
        }
        
        return activeWindow?.rootViewController
    }
    
    func topViewController(of viewController: UIViewController? = nil, rootViewController: UIViewController? = nil) -> UIViewController? {
        guard let rootViewController = rootViewController ?? keyWindow?.rootViewController else {
            return nil
        }
        
        let currentViewController = viewController ?? rootViewController
        
        if let tabBarController = currentViewController as? UITabBarController {
            return topViewController(of: tabBarController.selectedViewController, rootViewController: rootViewController)
        }
        
        if let navigationController = currentViewController as? UINavigationController {
            if let topViewController = navigationController.topViewController {
                return self.topViewController(of: topViewController, rootViewController: rootViewController)
            }
            let navVC = (firstNavigationContainer(from: currentViewController) as? UINavigationController) ?? childNavigationController(in: currentViewController)
            return navVC
        }
        
        return currentViewController.presentedViewController ?? currentViewController
    }
    
    /// 查找链上第一个已被 `UINavigationController` 包裹的 `UIViewController`
    /// - Parameter responder: 起始 `UIResponder`（通常是某个 View 或 VC）
    /// - Returns: 若存在，则返回对应的 `UIViewController`，否则为 `nil`
    private func firstNavigationContainer(from responder: UIResponder?) -> UIViewController? {
        var current = responder
        while let r = current {
            if let vc = r as? UIViewController, vc.navigationController != nil {
                return vc
            }
            current = r.next
        }
        return nil
    }
    private func childNavigationController(in viewController: UIViewController) -> UINavigationController? {
        for child in viewController.children {
            if let navigationController = child as? UINavigationController {
                return navigationController
            }
            return childNavigationController(in: child)
        }
        return nil
    }
    
    func topMostViewController(of viewController: UIViewController? = nil) -> UIViewController? {
        let currentViewController = viewController ?? keyWindow?.rootViewController
        
        /// presented view controlle
        if let presentedViewController = currentViewController?.presentedViewController {
            return topMostViewController(of: presentedViewController)
        }
        
        /// UINavigationController
        if let navigationController = currentViewController as? UINavigationController {
            return topMostViewController(of: navigationController.visibleViewController)
        }
        
        /// UITabBarController
        if let tabBarController = currentViewController as? UITabBarController {
            return topMostViewController(of: tabBarController.selectedViewController)
        }
        /// UIPageViewController
        if let pageViewController = currentViewController as? UIPageViewController {
            return topMostViewController(of: pageViewController.viewControllers?.first)
        }
        
        // child view controller
        for subview in currentViewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return topMostViewController(of: childViewController)
            }
        }
        return currentViewController
    }
    
    var visibleViewController: UIViewController? {
        if let activeViewController = activeViewController {
            if let navigationController = activeViewController as? UINavigationController {
                return navigationController.visibleViewController
            }
            return activeViewController
        }
        return nil
    }
    
    var activeViewController: UIViewController? {
        var viewController: UIViewController?
        let windows: [UIWindow]
        if #available(iOS 13.0, *) {
            windows = UIApplication.shared.connectedScenes.compactMap({
                ($0 as? UIWindowScene)?.windows
            }).flatMap({ $0 })
        } else {
            windows = UIApplication.shared.windows
        }
        
        var activeWindow: UIWindow?
        
        for window in windows {
            if window.windowLevel == UIWindow.Level.normal {
                activeWindow = window
                break
            }
        }
        
        if let activeWindow, activeWindow.subviews.count > 0 {
            let frontView: UIView? = activeWindow.subviews.last
            var responder: UIResponder? = frontView?.next
            
            while let nextResponder = responder, !nextResponder.isKind(of: UIWindow.self) {
                if nextResponder is UIViewController {
                    viewController = nextResponder as? UIViewController
                    break
                } else {
                    responder = nextResponder.next
                }
            }
            
            if let responder, responder is UIViewController {
                viewController = responder as? UIViewController
            } else {
                viewController = activeWindow.rootViewController
            }
            
            while viewController?.presentedViewController != nil {
                viewController = viewController?.presentedViewController
            }
        }
        
        return viewController
    }
}

private extension UINavigationController {
    func onCompleteAnimatedTransitoning(perform block: (() -> Void)?) {
        // 只有在“开始 push 后”才能拿到 coordinator
        guard let block else { return }
        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                // push 动画已结束
                block()
            }
        } else {
            // 没动画时立即回调
            block()
        }
    }
}

#endif
