import GameplayKit

final class GravitionalComponent: GKComponent {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
            fatalError("A GravitationComponent's entity must have a RenderComponent")
        }
        return renderComponent
    }

    var movementComponent: MovementComponent {
        guard let movementComponent = entity?.component(ofType: MovementComponent.self) else {
            fatalError("A GravitationComponent's entity must have a MovementComponent")
        }
        return movementComponent
    }
}
