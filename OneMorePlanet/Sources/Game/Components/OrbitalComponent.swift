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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Orbital

    func closestGravitationalComponent(in coordinator: EntityCoordinator) -> GravitionalComponent? {
        var closestGravitationalComponent: GravitionalComponent? = nil
        var closestDistance: CGFloat = 0.0
        let currentPosition = movementComponent.position
        let gravitationalComponents = coordinator.components(ofType: GravitionalComponent.self)

        for gravitationalComponent in gravitationalComponents {
            let movementComponent = gravitationalComponent.movementComponent
            let distance = (CGPoint(movementComponent.position) - CGPoint(currentPosition)).length()
            if closestGravitationalComponent == nil || distance < closestDistance {
                closestGravitationalComponent = gravitationalComponent
                closestDistance = distance
            }
        }

        return closestGravitationalComponent
    }
}
