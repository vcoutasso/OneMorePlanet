import GameKit

final class Planet: GKEntity {
    // MARK: - Initialization

    init(imageName: String, initialPosition: SIMD2<Float>) {
        super.init()

        let renderComponent = RenderComponent(texture: SKTexture(imageNamed: imageName))
        addComponent(renderComponent)

        let physicsBody =  SKPhysicsBody(circleOfRadius: renderComponent.node.frame.width / 2)
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: ColliderType.Obstacle)
        addComponent(physicsComponent)

        let gravitationalComponent = GravitionalComponent()
        addComponent(gravitationalComponent)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
