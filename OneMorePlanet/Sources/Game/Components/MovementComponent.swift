import GameKit
import SpriteKit

final class MovementComponent: GKAgent2D {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
            fatalError("A MovementComponent's entity must have a RenderComponent")
        }
        return renderComponent
    }

    // MARK: Initialization

    override init() {
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Methods

    func updatePosition(displacement: CGPoint, referencePoint: CGPoint, factor: CGFloat) {
        let dx = renderComponent.node.position.x - (displacement.x * factor)
        let dy = renderComponent.node.position.y - (displacement.y * factor)
        renderComponent.node.position = CGPoint(x: dx, y: dy)

        if renderComponent.node.position.x > referencePoint.x + GameplayConfiguration.Scene.halfWidth {
            renderComponent.node.position.x -= 2 * GameplayConfiguration.Scene.halfWidth
        } else if renderComponent.node.position.x < referencePoint.x - GameplayConfiguration.Scene.halfWidth {
            renderComponent.node.position.x += 2 * GameplayConfiguration.Scene.halfWidth
        } else if renderComponent.node.position.y > referencePoint.y - GameplayConfiguration.Scene.halfHeight {
            renderComponent.node.position.y -= 2 * GameplayConfiguration.Scene.halfHeight
        } else if renderComponent.node.position.y < referencePoint.y - GameplayConfiguration.Scene.halfHeight {
            renderComponent.node.position.y += 2 * GameplayConfiguration.Scene.halfHeight
        }
    }
}
