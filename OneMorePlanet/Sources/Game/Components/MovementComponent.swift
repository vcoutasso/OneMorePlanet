import SpriteKit
import GameKit

final class MovementComponent: GKAgent2D {
    // MARK: - Properties

    // MARK: - Initialization

    init(speed: Float) {
        super.init()
        self.speed = speed
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MovementComponent: GKAgentDelegate {
    func agentWillUpdate(_ agent: GKAgent) {
        guard let visualComponent = entity?.component(ofType: RenderComponent.self) else { return }

        position = SIMD2<Float>(x: visualComponent.node.position.x,
                                y: visualComponent.node.position.y)
    }

    func agentDidUpdate(_ agent: GKAgent) {
        guard let visualComponent = entity?.component(ofType: RenderComponent.self) else { return }

        visualComponent.node.position = CGPoint(x: position.x, y: position.y)
    }
}
