import GameKit
import SpriteKit

final class RenderComponent: GKComponent {
    // MARK: - Properties

    let node: SKSpriteNode

    // MARK: - Initialization

    init(texture: SKTexture) {
        self.node = SKSpriteNode(texture: texture)
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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
