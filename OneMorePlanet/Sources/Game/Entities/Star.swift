import GameplayKit

final class Star: GKEntity {
    // MARK: Properties

    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else {
            fatalError("A Star must have a RenderComponent")
        }
        return renderComponent
    }

    // MARK: - Initialization

    init(imageName: String, initialPosition _: SIMD2<Float>) {
        super.init()

        let renderComponent = RenderComponent(texture: SKTexture(imageNamed: imageName))
        renderComponent.node.setScale(GameplayConfiguration.Planet.renderComponentScale)
        addComponent(renderComponent)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
