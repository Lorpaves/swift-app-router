//
//  RouteStyle.swift
//  swift-app-router
//
//  Created by liujie on 2025/4/18.
//


public enum RouteStyle: Int {
    /// Push a view controller from navigation controller, it will ignore the children of the current navigation controller, and create a new controller to push it.
    case push
    /// Present a view controller from the top most viewcontroller which is active, it will ignore the view controllers which is presented, and create a new controller to present it.
    case modal
    /// Set the view controller as the current window's root view controller which is active.
    case asWindowRoot
    /// Set the view controller as the current window's root view controller which is active.
    case asWindowNavRoot
    /// Push to the target view controller, it will check it's navigation controller's stack, if find a view controller that is the same class of the view controller's, then navigate to the view controller.
    case navigateToTarget
    /// Push the view controller. If there is any modal view controller, dismiss them.
    case dismissModalsAndPush
}
