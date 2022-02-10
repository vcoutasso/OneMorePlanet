import GameplayKit
import SnapKit
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

    private var player = Player(imageName: "Images/alien")

    private lazy var leftAsteroidBelt = AsteroidBelt()
    private lazy var rightAsteroidBelt = AsteroidBelt()

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

    private lazy var topY: CGFloat = GameplayConfiguration.Planet.planetSpawnDistance

    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }

    lazy var blurEffect: SKEffectNode = {
        let node = SKEffectNode()
        let filter = CIFilter(name: "CIGaussianBlur")!
        let blurAmount = 10.0
        filter.setValue(blurAmount, forKey: kCIInputRadiusKey)
        node.filter = filter
        node.blendMode = .alpha
        node.shouldEnableEffects = false

        return node
    }()

    private lazy var scoreLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: Fonts.AldoTheApache.regular.name)
        node.fontSize = 50
        node.text = "\(score)"
        node.zPosition = 1
        let positionConstraint = SKConstraint.distance(SKRange(constantValue: .zero),
                                                       to: CGPoint(x: 0, y: size.height / 2 - 80))
        node.constraints = [positionConstraint]

        return node
    }()

    lazy var pauseButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let icon = UIImage(systemName: "pause.fill", withConfiguration: symbolConfiguration)
        button.setImage(icon, for: .normal)
        button.addTarget(self, action: #selector(pauseGame), for: .touchUpInside)

        return button
    }()

    lazy var resumeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(font: Fonts.AldoTheApache.regular, size: 35)
        label.text = "TOUCH TO CONTINUE"
        label.textColor = .white
        label.isHidden = true

        return label
    }()

    // MARK: Initializers

    override init(size: CGSize) {
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        unregisterForPauseNotifications()
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

        entityCoordinator.addEntity(player, to: .player)
        setEntityNodePosition(entity: player, position: CGPoint(x: 0.0, y: -size.height * 0.3))
        entityCoordinator.addEntity(leftAsteroidBelt, to: .game)
        setEntityNodePosition(entity: leftAsteroidBelt, position: CGPoint(x: -1.5 * size.width, y: 0.0))
        entityCoordinator.addEntity(rightAsteroidBelt, to: .game)
        setEntityNodePosition(entity: rightAsteroidBelt, position: CGPoint(x: 1.5 * size.width, y: 0.0))

        stateMachine.enter(GameSceneActiveState.self)

        setCameraConstraints()

        player.physicsComponent.physicsBody.applyImpulse(CGVector(dx: 0, dy: 20))

        view.addSubview(pauseButton)
        view.addSubview(resumeLabel)

        pauseButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.topMargin.equalToSuperview().offset(20)
        }

        resumeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.snp.bottomMargin).offset(-50)
        }

        #if DEBUG
            view.showsPhysics = true
        #endif
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        var referencePoint = player.renderComponent.node.position
        referencePoint = touches.first!.location(in: self)

        guard let nearestPlanet = player.orbitalComponent
            .nearestGravitationalComponent(in: entityCoordinator,
                                           to: referencePoint) else { return }

        nearestPlanetPosition = nearestPlanet.renderComponent.node.position
        nearestPlanetSize = nearestPlanet.renderComponent.node.size.width
        isInOrbit = true
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        isInOrbit = false
        if isReallyPaused {
            resumeGame()
        }
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

        if topY - player.renderComponent.node.position.y < GameplayConfiguration.Planet.planetSpawnDistance {
            spawnPlanet()
        }

        if isInOrbit {
            let direction = nearestPlanetPosition - player.renderComponent.node.position
            let velocity = player.renderComponent.node.physicsBody!.velocity
            let velocityPoint = CGPoint(x: velocity.dx, y: velocity.dy)
            var velocityLength = velocityPoint.length()
            let maxVelocity = GameplayConfiguration.Player.maxSpeed
            if velocityLength > maxVelocity {
                let newVelocityPoint = maxVelocity * (velocityPoint / velocityLength)
                player.physicsComponent.physicsBody.velocity = CGVector(dx: newVelocityPoint.x, dy: newVelocityPoint.y)
                velocityLength = maxVelocity
            }
            let normalizedDirection = direction / direction.length()
            let force = deltaTime * 10 * velocityLength * normalizedDirection
            player.physicsComponent.physicsBody.applyForce(CGVector(dx: force.x, dy: force.y))
        } else {
            if player.renderComponent.node.physicsBody!.velocity == .zero {
                stateMachine.enter(GameSceneGameOverState.self)
            }
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

        let initialPosition: SIMD2<Float> = .init(x: Float(xCoordinate),
                                                  y: Float(camera!.frame.maxY + view!.frame.height))
        let newPlanet = Planet(imageName: "Images/planet\(randomPlanetID)", initialPosition: initialPosition)
        setEntityNodePosition(entity: newPlanet, position: CGPoint(x: initialPosition.x, y: initialPosition.y))

        entityCoordinator.addEntity(newPlanet, to: .game)

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

    @objc private func resumeGame() {
        stateMachine.enter(GameSceneActiveState.self)
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
