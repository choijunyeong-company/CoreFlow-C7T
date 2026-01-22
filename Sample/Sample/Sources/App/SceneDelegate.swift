import CoreFlow
import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var rootFlow: RootFlow?
    var store: Set<AnyCancellable> = []

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let rootFlow = RootFlow(listener: self)
        self.rootFlow = rootFlow
        
        window.rootViewController = UINavigationController(
            rootViewController: rootFlow.screen
        )
        window.makeKeyAndVisible()
    }
}

extension SceneDelegate: RootListener {
    func rootIsReady() {
        guard let rootFlow else { return }
        
        LaunchProcedure()
            .start(rootFlow.core) {
                print("Procedure finished")
            }
    }
}
