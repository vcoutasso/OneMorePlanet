import GameplayKit

final class EntityCoordinator {
    // MARK: Properties
    
    private let scene: GameSceneProtocol

    private var entities = Set<GKEntity>()

    // MARK: Component Systems

    private(set) lazy var componentSystems: [GKComponentSystem] = {
        let movementSystem = GKComponentSystem(componentClass: MovementComponent.self)

        return [movementSystem]
    }()

    // MARK: Initialization

    init(scene: GameSceneProtocol) {
        self.scene = scene
    }

    func updateComponentSystems(deltaTime: TimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)

            // FIXME: Clean  this up
            let components = componentSystem.components
            for component in components {
                guard let movementComponent = component as? MovementComponent else {
                    return
                }
                if movementComponent.position.y < -5000 {
                    removeEntity(movementComponent.entity!)
                }
            }
        }
    }

    func addEntity(_ entity: GKEntity) {
        entities.insert(entity)

        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }

        if let renderNode = entity.component(ofType: RenderComponent.self)?.node {
            scene.addNode(node: renderNode, toWorldLayer: .planets)
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

    func components<ComponentType>(ofType: ComponentType.Type) -> [ComponentType] where ComponentType: GKComponent {
        var components = [ComponentType]()

        for entity in entities {
            if let component = entity.component(ofType: ComponentType.self) {
                components.append(component)
            }
        }

        return components
    }
}
