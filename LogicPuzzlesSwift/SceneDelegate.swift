//
//  SceneDelegate.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2026/09/17.
//  Copyright © 2026 趙偉. All rights reserved.
//


import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 使用此方法来配置和附加 window 到提供的 UIWindowScene。
        // 如果使用了 storyboard，window 属性会自动初始化并附加到 scene 上。
        // 这个 delegate 并不意味着连接 scene 或 session 是新的（参见 application:configurationForConnectingSceneSession:）。
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    // 根据情况，你可能还需要将 AppDelegate 中的其他生命周期方法迁移到此处。
    // 例如：
    // func sceneDidDisconnect(_ scene: UIScene) { }
    // func sceneDidBecomeActive(_ scene: UIScene) { }
    // func sceneWillResignActive(_ scene: UIScene) { }
    // func sceneWillEnterForeground(_ scene: UIScene) { }
    // func sceneDidEnterBackground(_ scene: UIScene) { }
}