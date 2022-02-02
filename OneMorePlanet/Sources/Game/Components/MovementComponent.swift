import SpriteKit
import GameKit

final class MovementComponent: GKAgent2D {
    // MARK: Initialization

    init(behavior: GKBehavior) {
        super.init()

        self.delegate = self
        self.behavior = behavior
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: GKAgent2D

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    }
}

extension MovementComponent: GKAgentDelegate {
    func agentWillUpdate(_ agent: GKAgent) {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { return }

        position = SIMD2<Float>(x: renderComponent.node.position.x,
                                y: renderComponent.node.position.y)
    }

    func agentDidUpdate(_ agent: GKAgent) {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { return }

        renderComponent.node.position = CGPoint(x: position.x, y: position.y)
    }
}
