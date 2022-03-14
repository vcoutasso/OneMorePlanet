import GameplayKit

final class Star: GKEntity {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else {
            fatalError("A Star must have a RenderComponent")
        }
        return renderComponent
    }

    var movementComponent: MovementComponent {
        guard let movementComponent = component(ofType: MovementComponent.self) else {
            fatalError("A Star must have a MovementComponent")
        }
        return movementComponent
    }

    let distance: DistanceQualifier
    let displacementFactor: CGFloat

    // MARK: - Initialization

    init(imageName: String, distance: DistanceQualifier) {
        self.distance = distance
        self.displacementFactor = distance.randomDisplacementFactor

        super.init()

        let renderComponent = RenderComponent(texture: SKTexture(imageNamed: imageName))
        renderComponent.node.setScale(displacementFactor * GameplayConfiguration.Star.renderComponentScaleFactor)
        renderComponent.node.blendMode = .screen
        addComponent(renderComponent)

        let movementComponent = MovementComponent()
        addComponent(movementComponent)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum DistanceQualifier: CaseIterable {
    case near
    case moderate
    case far

    var randomDisplacementFactor: CGFloat {
        switch self {
        case .near:
            return .random(in: GameplayConfiguration.Star.nearDisplacementMultiplierRange)
        case .moderate:
            return .random(in: GameplayConfiguration.Star.moderateDisplacementMultiplierRange)
        case .far:
            return .random(in: GameplayConfiguration.Star.farDisplacementMultiplierRange)
        }
    }

    static func random() -> DistanceQualifier {
        DistanceQualifier.allCases.randomElement()!
    }
}
