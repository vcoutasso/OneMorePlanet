import SpriteKit
import GameKit

final class RenderComponent: GKComponent {
    // MARK: - Properties

    let node: SKSpriteNode

    // MARK: - Initialization

    init(texture: SKTexture) {
        self.node = SKSpriteNode(texture: texture)
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: GKComponent

    override func didAddToEntity() {
        node.entity = entity
    }

    override func willRemoveFromEntity() {
        node.entity = nil
    }
}
