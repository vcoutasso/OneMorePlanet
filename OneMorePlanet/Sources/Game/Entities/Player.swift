import GameKit

final class Player: GKEntity {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else {
            fatalError("A Player must have a RenderComponent")
        }
        return renderComponent
    }

    var orbitalComponent: OrbitalComponent {
        guard let orbitalComponent = component(ofType: OrbitalComponent.self) else {
            fatalError("A Player must have a OrbitalComponent")
        }
        return orbitalComponent
    }

    // MARK: Initialization

    init(imageName: String) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        let renderComponent = RenderComponent(texture: texture)

        addComponent(renderComponent)

        let movementComponent = MovementComponent(behavior: nil)
        addComponent(movementComponent)

        let orbitalComponent = OrbitalComponent()
        addComponent(orbitalComponent)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
