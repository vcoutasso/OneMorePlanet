import GameplayKit
import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: Properties

    private lazy var worldLayerNodes = WorldLayer.allLayers
        .reduce(into: [WorldLayer: SKNode]()) { partialResult, layer in
            partialResult[layer] = SKNode()
        }

    var isReallyPaused: Bool = false {
        didSet {
            isPaused = isReallyPaused
        }
    }

    private let player = Player(imageName: "Images/alien")

    private let leftAsteroidBelt = AsteroidBelt()
    private let rightAsteroidBelt = AsteroidBelt()

    private var lastUpdateTimeInterval: TimeInterval = 0
    private let maxUpdateTimeInterval: TimeInterval = 1.0 / 60.0

    private lazy var stateMachine = GKStateMachine(states: [
        GameSceneActiveState(gameScene: self),
        GameScenePauseState(gameScene: self),
        GameSceneOverlayState(gameScene: self),
        GameSceneGameOverState(gameScene: self),
    ])

    private lazy var entityCoordinator = EntityCoordinator(scene: self)

    private var repeatingAction: SKAction!

    private var isInOrbit = false

    let backgroundStarsNode = SKSpriteNode(texture: SKTexture(imageNamed: "Images/Stars"))

    private var nearestPlanetPosition: CGPoint = .zero

    private var nearestPlanetSize: CGFloat = .zero

    private lazy var topY: CGFloat = 400

    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }

    private lazy var scoreLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: "aldotheapache")
        node.fontSize = 50
        node.text = "\(score)"
        node.zPosition = 1
        let positionConstraint = SKConstraint.distance(SKRange(constantValue: .zero), to: CGPoint(x: 0, y: size.height / 2 - 80))
        node.constraints = [positionConstraint]

        return node
    }()

    // MARK: Initializers

    // FIXME: Minor memory leak going on here
    deinit {
        unregisterForPauseNotifications()
        entityCoordinator.removeAllEntities()
        removeAllChildren()
        removeAllActions()
        debugPrint("GameScene deinited")
    }

    // MARK: Scene Life Cycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        registerForPauseNotifications()

        backgroundColor = UIColor(named: "Colors/SpaceBackground")!
        backgroundStarsNode.position = .zero
        backgroundStarsNode.zPosition = -1

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        let emitter = SKEmitterNode(fileNamed: "MyBokeh")!
        player.renderComponent.node.addChild(emitter)
        emitter.targetNode = self

        addWorldLayers()

        let camera = SKCameraNode()
        camera.addChild(scoreLabel)
        self.camera = camera

        addChild(backgroundStarsNode)
        addChild(camera)

        entityCoordinator.addEntity(player)
        setEntityNodePosition(entity: player, position: CGPoint(x: 0.0, y: -size.height * 0.3))
        entityCoordinator.addEntity(leftAsteroidBelt)
        setEntityNodePosition(entity: leftAsteroidBelt, position: CGPoint(x: -1.5 * size.width, y: 0.0))
        entityCoordinator.addEntity(rightAsteroidBelt)
        setEntityNodePosition(entity: rightAsteroidBelt, position: CGPoint(x: 1.5 * size.width, y: 0.0))

        stateMachine.enter(GameSceneActiveState.self)

        setCameraConstraints()

        player.physicsComponent.physicsBody.applyImpulse(CGVector(dx: 0, dy: 20))

        #if DEBUG
            view.showsPhysics = true
        #endif
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        guard let nearestPlanet = player.orbitalComponent.closestGravitationalComponent(in: entityCoordinator) else { return }

        nearestPlanetPosition = nearestPlanet.renderComponent.node.position
        nearestPlanetSize = nearestPlanet.renderComponent.node.size.width
        isInOrbit = true

        if stateMachine.currentState is GameScenePauseState {
            stateMachine.enter(GameSceneActiveState.self)
        }
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        isInOrbit = false
    }

    func didBegin(_: SKPhysicsContact) {
        stateMachine.enter(GameSceneGameOverState.self)
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        guard view != nil else { return }

        var deltaTime = currentTime - lastUpdateTimeInterval

        deltaTime = deltaTime > maxUpdateTimeInterval ? maxUpdateTimeInterval : deltaTime

        lastUpdateTimeInterval = currentTime

        if isReallyPaused { return }

        stateMachine.update(deltaTime: deltaTime)

        entityCoordinator.updateComponentSystems(deltaTime: deltaTime)

        backgroundStarsNode.position = camera!.position
        leftAsteroidBelt.renderComponent.node.position.y = camera!.position.y
        rightAsteroidBelt.renderComponent.node.position.y = camera!.position.y

        if topY - player.renderComponent.node.position.y < 400 {
            spawnPlanet()
        }

        if isInOrbit {
            let direction = nearestPlanetPosition - player.renderComponent.node.position
            let velocity = player.renderComponent.node.physicsBody!.velocity
            let velocityPoint = CGPoint(x: velocity.dx, y: velocity.dy)
            var velocityLength = velocityPoint.length()
            let maxVelocity = 350.0
            if velocityLength > maxVelocity {
                print("Max velocity")
                let newVelocityPoint = maxVelocity * (velocityPoint / velocityLength)
                player.physicsComponent.physicsBody.velocity = CGVector(dx: newVelocityPoint.x, dy: newVelocityPoint.y)
                velocityLength = maxVelocity
            }
            let normalizedDirection = direction / direction.length()
            let force = deltaTime * 10 * velocityLength * normalizedDirection
            player.physicsComponent.physicsBody.applyForce(CGVector(dx: force.x, dy: force.y))
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

        let xCoordinate = size.width * CGFloat.random(in: -0.45 ... 0.45)

        let initialPosition: SIMD2<Float> = .init(x: Float(xCoordinate), y: Float(camera!.frame.maxY + view!.frame.height))
        let newPlanet = Planet(imageName: "Images/planet\(randomPlanetID)", initialPosition: initialPosition)
        setEntityNodePosition(entity: newPlanet, position: CGPoint(x: initialPosition.x, y: initialPosition.y))

        entityCoordinator.addEntity(newPlanet)

        topY += CGFloat.random(in: 150 ... 300)
        score += 1
    }

    private func setEntityNodePosition(entity: GKEntity, position: CGPoint) {
        guard let renderComponent = entity.component(ofType: RenderComponent.self) else { return }

        renderComponent.node.position = position
    }

    // MARK: Convenience

    func startNewGame() {
        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode
        let animation = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(newScene, transition: animation)
    }

    private func setCameraConstraints() {
        guard let camera = camera else { return }

        let zeroRange = SKRange(constantValue: .zero)
        let playerNode = player.renderComponent.node
        let playerLocationConstraint = SKConstraint.distance(zeroRange, to: playerNode)

        camera.constraints = [playerLocationConstraint]
    }
}

// MARK: - Extensions

/// Pause
extension GameScene {
    // MARK: Properties

    override var isPaused: Bool {
        didSet {
            if isPaused != isReallyPaused {
                isPaused = isReallyPaused
            }
        }
    }

    private var pauseNotificationName: NSNotification.Name {
        UIApplication.willResignActiveNotification
    }

    @objc private func pauseGame() {
        stateMachine.enter(GameScenePauseState.self)
    }

    // MARK: Convenience methods

    private func registerForPauseNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(pauseGame),
                         name: pauseNotificationName,
                         object: nil)
    }

    private func unregisterForPauseNotifications() {
        NotificationCenter.default
            .removeObserver(self,
                            name: pauseNotificationName,
                            object: nil)
    }
}
