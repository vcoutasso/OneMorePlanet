import GameplayKit

final class PhysicsComponent: GKComponent {
    // MARK: Properties

    let physicsBody: SKPhysicsBody

    var renderComponent: RenderComponent {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
            fatalError("A MovementComponent's entity must have a RenderComponent")
        }
        return renderComponent
    }

    // MARK: Initialization

    init(physicsBody: SKPhysicsBody, colliderType: ColliderType) {
        self.physicsBody = physicsBody
        super.init()
        updateColliderType(colliderType)
    }

    func updateColliderType(_ colliderType: ColliderType) {
        physicsBody.categoryBitMask = colliderType.categoryMask
        physicsBody.collisionBitMask = colliderType.collisionMask
        physicsBody.contactTestBitMask = colliderType.contactMask
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
