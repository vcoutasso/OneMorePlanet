import GameplayKit

final class OrbitalComponent: GKComponent {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
            fatalError("A OrbitalComponent's entity must have a RenderComponent")
        }
        return renderComponent
    }

    var movementComponent: MovementComponent {
        guard let movementComponent = entity?.component(ofType: MovementComponent.self) else {
            fatalError("A OrbitalComponent's entity must have a MovementComponent")
        }
        return movementComponent
    }

    // MARK: Initialization

    override init() {
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Orbital

    func nearestGravitationalComponent(in coordinator: EntityCoordinator,
                                       to referencePoint: CGPoint) -> GravitionalComponent? {
        var nearestGravitationalComponent: GravitionalComponent?
        var nearestDistance: CGFloat = 0.0
        let gravitationalComponents = coordinator.components(ofType: GravitionalComponent.self)

        for gravitationalComponent in gravitationalComponents {
            let renderComponent = gravitationalComponent.renderComponent
            let distance = (renderComponent.node.position - referencePoint).length()
            if nearestGravitationalComponent == nil || distance < nearestDistance {
                nearestGravitationalComponent = gravitationalComponent
                nearestDistance = distance
            }
        }

        return nearestGravitationalComponent
    }
}
