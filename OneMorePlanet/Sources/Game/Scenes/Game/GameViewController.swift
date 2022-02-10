import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = view as? SKView else { return }

        let scene = GameScene(size: view.frame.size)
        scene.scaleMode = .resizeFill

        view.presentScene(scene)

        view.ignoresSiblingOrder = true

        #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
        #endif
    }

    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
