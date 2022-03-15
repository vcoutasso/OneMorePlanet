import GameKit

final class Player: GKEntity {
    // MARK: - Components

    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else {
            fatalError("A Player must have a RenderComponent")
        }
        return renderComponent
    }

    var orbitalComponent: OrbitalComponent {
        guard let orbitalComponent = component(ofType: OrbitalComponent.self) else {
            fatalError("A Player must have an OrbitalComponent")
        }
        return orbitalComponent
    }

    var physicsComponent: PhysicsComponent {
        guard let physicsComponent = component(ofType: PhysicsComponent.self) else {
            fatalError("A Player must have a PhysicsComponent")
        }
        return physicsComponent
    }

    var lifeComponent: LivesComponent {
        guard let lifeComponent = component(ofType: LivesComponent.self) else {
            fatalError("A Player must have a LivesComponent")
        }
        return lifeComponent
    }

    // MARK: Initialization

    init(imageName: String) {
        super.init()

        createComponents(with: imageName)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Methods

    func becomeInvincible(for duration: TimeInterval) {
        let blinkForeverActionKey = "blinkForever"

        physicsComponent.updateColliderType(.none)

        let fadeIn = SKAction.fadeIn(withDuration: GameplayConfiguration.Player.invincibilityBlinkingFadeDuration)

        let fadeOut = SKAction.fadeOut(withDuration: GameplayConfiguration.Player.invincibilityBlinkingFadeDuration)

        let blinkAction = SKAction.sequence([
            fadeOut,
            fadeIn,
        ])
        let repeatBlinkAction = SKAction.repeatForever(blinkAction)

        renderComponent.node.run(repeatBlinkAction, withKey: blinkForeverActionKey)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.physicsComponent.updateColliderType(.player)
            self?.renderComponent.node.removeAction(forKey: blinkForeverActionKey)
            self?.renderComponent.node.run(fadeIn)
        }
    }
}

// MARK: - Convenience Methods

extension Player {
    private func createComponents(with imageName: String) {
        createRenderComponent(with: imageName)
        createOrbitalComponent()
        createPhysicsComponent()
        createLifeComponent()
    }

    private func createRenderComponent(with imageName: String) {
        let texture = SKTexture(imageNamed: imageName)

        let renderComponent = RenderComponent(texture: texture)
        renderComponent.node.setScale(GameplayConfiguration.Player.renderComponentScale)
        addComponent(renderComponent)
    }

    private func createOrbitalComponent() {
        let orbitalComponent = OrbitalComponent()
        addComponent(orbitalComponent)
    }

    private func createPhysicsComponent() {
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.Player.physicsBodyCircleRadius)
        physicsBody.linearDamping = GameplayConfiguration.Player.physicsBodyLinearDamping
        physicsBody.mass = GameplayConfiguration.Player.physicsBodyMass
        physicsBody.allowsRotation = false

        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .player)
        renderComponent.node.physicsBody = physicsBody
        addComponent(physicsComponent)
    }

    private func createLifeComponent() {
        let lifeComponent = LivesComponent(maximumLives: GameplayConfiguration.Player.maximumLives)
        addComponent(lifeComponent)
    }
}
