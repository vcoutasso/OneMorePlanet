import SpriteKit
import GameplayKit

protocol GameSceneProtocol {
    func addNode(node: SKNode, toWorldLayer worldLayer: WorldLayer)
}

final class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneProtocol {
    // MARK: Properties

    private lazy var worldLayerNodes = WorldLayer.allLayers.reduce(into: [WorldLayer: SKNode]()) { partialResult, layer in
        partialResult[layer] = SKNode()
    }

    private let player = Player(imageName: "Images/alien")

    private let leftAsteroidBelt = AsteroidBelt()
    private let rightAsteroidBelt = AsteroidBelt()

    private var lastUpdateTimeInterval: TimeInterval = 0
    private let maxUpdateTimeInterval: TimeInterval = 1.0 / 60.0

    private lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
    ])

    private lazy var entityCoordinator = EntityCoordinator(scene: self)

    private var repeatingAction: SKAction!

    private var isInOrbit = false

    let backgroundStarsNode = SKSpriteNode(texture: SKTexture(imageNamed: "Images/Stars"))

    private var nearestPlanetPosition: CGPoint = .zero

    private lazy var topY: CGFloat = 400

    // MARK: Scene Life Cycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        backgroundColor = UIColor(named: "Colors/SpaceBackground")!
        backgroundStarsNode.position = .zero
        backgroundStarsNode.zPosition = -1

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        addWorldLayers()

        addChild(backgroundStarsNode)

        let camera = SKCameraNode()
        self.camera = camera
        addChild(camera)

        entityCoordinator.addEntity(player)
        setEntityNodePosition(entity: player, position: CGPoint(x: 0.0, y: -size.height * 0.3))
        entityCoordinator.addEntity(leftAsteroidBelt)
        setEntityNodePosition(entity: leftAsteroidBelt, position: CGPoint(x: -size.width, y: 0.0))
        entityCoordinator.addEntity(rightAsteroidBelt)
        setEntityNodePosition(entity: rightAsteroidBelt, position: CGPoint(x: size.width, y: 0.0))

        setCameraConstraints()
        player.physicsComponent.physicsBody.applyImpulse(CGVector(dx: 0, dy: 20))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let nearestPlanet = player.orbitalComponent.closestGravitationalComponent(in: entityCoordinator) else { return }

        nearestPlanetPosition = nearestPlanet.renderComponent.node.position
        isInOrbit = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isInOrbit = false
    }

    func didBegin(_ contact: SKPhysicsContact) {
        isPaused = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        guard view != nil else { return }

        leftAsteroidBelt.renderComponent.node.position.y = self.camera!.position.y
        rightAsteroidBelt.renderComponent.node.position.y = self.camera!.position.y

        var deltaTime = currentTime - lastUpdateTimeInterval

        deltaTime = deltaTime > maxUpdateTimeInterval ? maxUpdateTimeInterval : deltaTime

        lastUpdateTimeInterval = currentTime

        stateMachine.update(deltaTime: deltaTime)

        entityCoordinator.updateComponentSystems(deltaTime: deltaTime)

        backgroundStarsNode.position = self.camera!.position

        if topY - player.renderComponent.node.position.y < 400 {
            spawnPlanet()
        }

        if isInOrbit {
            let direction = nearestPlanetPosition - player.renderComponent.node.position
            let normalizedDirection = direction / direction.length()
            let force = 120 * normalizedDirection
            player.renderComponent.node.physicsBody!.applyForce(CGVector(dx: force.x, dy: force.y))
        }
    }

    // MARK: Level Construction

    func addNode(node: SKNode, toWorldLayer worldLayer: WorldLayer) {
        guard let worldLayerNode = worldLayerNodes[worldLayer] else { return }

        worldLayerNode.addChild(node)
    }

    private func addWorldLayers() {
        for layer in WorldLayer.allLayers {
            addChild(worldLayerNodes[layer]!)
            worldLayerNodes[layer]!.zPosition = layer.rawValue
        }
    }

    private func spawnPlanet() {
        let randomPlanetID = GKRandomDistribution(lowestValue: 1, highestValue: 27).nextInt()

        let xCoordinate = size.width * CGFloat.random(in: -0.45...0.45)

        let initialPosition: SIMD2<Float> = .init(x: Float(xCoordinate), y: Float(camera!.frame.maxY + view!.frame.height))
        let newPlanet = Planet(imageName: "Images/planet\(randomPlanetID)", initialPosition: initialPosition)
        setEntityNodePosition(entity: newPlanet, position: CGPoint(x: initialPosition.x, y: initialPosition.y))

        entityCoordinator.addEntity(newPlanet)

        topY += CGFloat.random(in: 100...300)
    }

    private func setEntityNodePosition(entity: GKEntity, position: CGPoint) {
        guard let renderComponent = entity.component(ofType: RenderComponent.self) else { return }

        renderComponent.node.position = position
    }

    // MARK: Helper

    private func setCameraConstraints() {
        guard let camera = camera else { return }

        let zeroRange = SKRange(constantValue: .zero)
        let playerNode = player.renderComponent.node
        let playerLocationConstraint = SKConstraint.distance(zeroRange, to: playerNode)

        camera.constraints = [playerLocationConstraint]
    }
}
