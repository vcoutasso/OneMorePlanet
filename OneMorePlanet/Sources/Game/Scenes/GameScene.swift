import SpriteKit
import GameplayKit

protocol GameSceneProtocol {
    func addNode(node: SKNode, toWorldLayer worldLayer: WorldLayer)
}

final class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneProtocol {
    // MARK: Properties

    private var worldLayerNodes = WorldLayer.allLayers.reduce(into: [WorldLayer: SKNode]()) { partialResult, layer in
        partialResult[layer] = SKNode()
    }

    private let player = Player(imageName: "Images/alien")

    private var lastUpdateTimeInterval: TimeInterval = 0
    private let maxUpdateTimeInterval: TimeInterval = 1.0 / 60.0

    private lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
    ])

    private lazy var entityCoordinator = EntityCoordinator(scene: self)

    private var repeatingAction: SKAction!

    // MARK: Scene Life Cycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        anchorPoint = CGPoint(x: 0.0, y: 0.0)

        // Add background
        backgroundColor = UIColor(named: "Colors/SpaceBackground")!
        let backgroundStarsNode = SKSpriteNode(texture: SKTexture(imageNamed: "Images/Stars"))
        backgroundStarsNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundStarsNode.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundStarsNode.zPosition = -1
        addChild(backgroundStarsNode)

        addWorldLayers()

        let planetSpawnInterval = SKAction.wait(forDuration: GameplayConfiguration.Planet.spawnInterval)
        let planetSpawnAction = SKAction.run { [weak self] in
            self?.spawnPlanet()
        }
        let planetSpawnSequence = SKAction.sequence([planetSpawnAction, planetSpawnInterval])

        run(SKAction.repeatForever(planetSpawnSequence))

        entityCoordinator.addEntity(player)
        setEntityNodePosition(entity: player, position: CGPoint(x: frame.size.width / 2,
                                                                y: frame.size.height * 0.2))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(player.orbitalComponent.closestGravitationalComponent(in: entityCoordinator)?.movementComponent.position)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    func didBegin(_ contact: SKPhysicsContact) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        guard view != nil else { return }

        var deltaTime = currentTime - lastUpdateTimeInterval

        deltaTime = deltaTime > maxUpdateTimeInterval ? maxUpdateTimeInterval : deltaTime

        lastUpdateTimeInterval = currentTime

        stateMachine.update(deltaTime: deltaTime)

        entityCoordinator.updateComponentSystems(deltaTime: deltaTime)
    }

    // MARK: Level Construction

    func addNode(node: SKNode, toWorldLayer worldLayer: WorldLayer) {
        guard let worldLayerNode = worldLayerNodes[worldLayer] else { return }

        worldLayerNode.addChild(node)
    }

    private func addWorldLayers() {
        for layer in WorldLayer.allLayers {
            addChild(worldLayerNodes[layer]!)
        }
    }

    private func spawnPlanet() {
        let randomPlanetID = GKRandomDistribution(lowestValue: 1, highestValue: 27).nextInt()
        let randomInteger = GKRandomDistribution(lowestValue: 10, highestValue: 90).nextInt()

        let xCoordinate = frame.size.width * (CGFloat(randomInteger) / 100.0)

        let initialPosition: SIMD2<Float> = .init(x: Float(xCoordinate), y: Float(frame.size.height))
        let targetPosition: SIMD2<Float> = .init(x: Float(xCoordinate), y: 0.0)
        let newPlanet = Planet(imageName: "Images/planet\(randomPlanetID)", initialPosition: initialPosition, targetPosition: targetPosition)
        setEntityNodePosition(entity: newPlanet, position: CGPoint(x: initialPosition.x, y: initialPosition.y))

        entityCoordinator.addEntity(newPlanet)
    }

    private func setEntityNodePosition(entity: GKEntity, position: CGPoint) {
        guard let renderComponent = entity.component(ofType: RenderComponent.self) else { return }

        renderComponent.node.position = position
    }
}
