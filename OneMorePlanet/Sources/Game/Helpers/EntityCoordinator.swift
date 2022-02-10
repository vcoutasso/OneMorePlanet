import GameplayKit

final class EntityCoordinator {
    // MARK: Properties

    private unowned let scene: GameScene

    private var entities = Set<GKEntity>()

    // MARK: Component Systems

    private(set) lazy var componentSystems: [GKComponentSystem] = {
        let movementSystem = GKComponentSystem(componentClass: MovementComponent.self)

        return [movementSystem]
    }()

    // MARK: Initialization

    init(scene: GameScene) {
        self.scene = scene
    }

    func updateComponentSystems(deltaTime: TimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
    }

    func addEntity(_ entity: GKEntity, to layer: WorldLayer) {
        entities.insert(entity)

        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }

        if let renderNode = entity.component(ofType: RenderComponent.self)?.node {
            scene.addNode(node: renderNode, toWorldLayer: layer)
        }
    }

    func removeEntity(_ entity: GKEntity) {
        entities.remove(entity)

        for componentSystem in componentSystems {
            componentSystem.removeComponent(foundIn: entity)
        }

        if let renderNode = entity.component(ofType: RenderComponent.self)?.node {
            renderNode.removeFromParent()
        }
    }

    func removeAllEntities() {
        for entity in entities {
            removeEntity(entity)
        }
    }

    func components<ComponentType>(ofType _: ComponentType.Type) -> [ComponentType] where ComponentType: GKComponent {
        var components = [ComponentType]()

        for entity in entities {
            if let component = entity.component(ofType: ComponentType.self) {
                components.append(component)
            }
        }

        return components
    }
}
