import GameKit

final class Player: GKEntity {

    // MARK: - Components

    private let renderComponent: RenderComponent

    // MARK: - Initialization

    init(imageName: String) {
        let texture = SKTexture(imageNamed: imageName)
        renderComponent = RenderComponent(texture: texture)

        super.init()
        addComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helper methods

    private func addComponents() {
        addComponent(renderComponent)
    }
}
