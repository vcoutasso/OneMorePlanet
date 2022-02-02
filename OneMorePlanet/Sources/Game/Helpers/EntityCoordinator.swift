import GameplayKit

final class EntityCoordinator {
    // MARK: Properties
    
    private let scene: GameSceneProtocol

    private var entities = Set<GKEntity>()

    // MARK: Component Systems

    private lazy var componentSystems: [GKComponentSystem] = {
        return [GKComponentSystem]()
    }()

    // MARK: Initialization

    init(scene: GameSceneProtocol) {
        self.scene = scene
    }

    func updateComponentSystems(deltaTime: TimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
    }

    func addEntity(_ entity: GKEntity) {
        entities.insert(entity)

        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }

        if let renderNode = entity.component(ofType: RenderComponent.self)?.node {
            scene.addNode(node: renderNode, toWorldLayer: .middle)
        }
    }

    func removeEntity(_ entity: GKEntity) {
        if let renderNode = entity.component(ofType: RenderComponent.self)?.node {
            renderNode.removeFromParent()
        }

        entities.remove(entity)

        for componentSystem in componentSystems {
            componentSystem.removeComponent(foundIn: entity)
        }
    }
}
