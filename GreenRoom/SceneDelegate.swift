//
//  SceneDelegate.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/08/01.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import NaverThirdPartyLogin

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let mainTabbarController = UITabBarController()
        
        let greenRoomController = UINavigationController(rootViewController: GreenRoomViewController())
        let keywordController = UINavigationController(rootViewController: KPMainViewController(viewModel: KeywordViewModel()))
        let mypageController = UINavigationController(rootViewController: MyPageViewController(viewModel: MyPageViewModel()))
        
        greenRoomController.title = "그린룸"
        greenRoomController.tabBarItem.image = UIImage(named: "greenroom")
        keywordController.title = "키워드연습"
        keywordController.tabBarItem.image = UIImage(named: "keyword")
        mypageController.title = "마이페이지"
        mypageController.tabBarItem.image = UIImage(named: "mypage")
        
        mainTabbarController.tabBar.tintColor = .darken
        mainTabbarController.tabBar.unselectedItemTintColor = .customGray
        mainTabbarController.viewControllers = [keywordController,greenRoomController,mypageController]
        mainTabbarController.selectedIndex = 1
        
        
        window?.rootViewController = mainTabbarController
        window?.makeKeyAndVisible()
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        //kakao
        guard let url =  URLContexts.first?.url else { return }
        
        let str = url.absoluteString
        
        if str.hasPrefix("kakao"){ // kakao
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }else{ // naver
            NaverThirdPartyLoginConnection
              .getSharedInstance()?
              .receiveAccessToken(url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

