import FirebaseAnalytics
import GameKit
import GameplayKit
import SnapKit
import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: Properties

    unowned let gameOverDelegate: GameOverDelegate

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

    private lazy var upperAsteroidBelt = AsteroidBelt()
    private lazy var lowerAsteroidBelt = AsteroidBelt()

    private var lastUpdateTimeInterval: TimeInterval = 0
    private let maxUpdateTimeInterval: TimeInterval = 1.0 / 60.0

    private lazy var stateMachine = GKStateMachine(states: [
        GameSceneActiveState(gameScene: self),
        GameScenePauseState(gameScene: self),
        GameSceneOverlayState(gameScene: self),
        GameSceneGameOverState(gameScene: self),
        GameSceneNewGameState(gameScene: self),
    ])

    private lazy var entityCoordinator = EntityCoordinator(scene: self)

    private let highScoreStore = HighScoreStore()

    private var isInOrbit = false

    private let backgroundStarsNode = SKSpriteNode(texture: SKTexture(imageNamed: Assets.Images.stars.name))

    private var nearestPlanetPosition: CGPoint = .zero

    private var nearestPlanetSize: CGFloat = .zero

    private var isFirstPlanet: Bool = true

    private lazy var topY: CGFloat = GameplayConfiguration.Planet.planetSpawnDistance

    private var maxY: CGFloat = 0

    private(set) var score: Score = .zero {
        didSet {
            scoreLabel.text = "\(score.value)"
        }
    }

    private(set) lazy var currentBest: Score = highScoreStore.fetchHighScore() {
        didSet {
            currentBestLabel.text = "Best: \(currentBest.value)"
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
        node.text = "\(score.value)"
        node.zPosition = 1
        let positionConstraint = SKConstraint.distance(SKRange(constantValue: .zero),
                                                       to: CGPoint(x: 0, y: size.height / 2 - 100))
        node.constraints = [positionConstraint]

        return node
    }()

    private lazy var currentBestLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: Fonts.AldoTheApache.regular.name)
        node.fontSize = 20
        node.text = "Best: \(currentBest.value)"
        node.zPosition = 1
        let positionConstraint = SKConstraint.distance(SKRange(constantValue: .zero),
                                                       to: CGPoint(x: 0, y: size.height / 2 - 130))
        node.constraints = [positionConstraint]

        return node
    }()

    lazy var resumeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(font: Fonts.AldoTheApache.regular, size: 35)
        label.text = "TOUCH TO CONTINUE"
        label.textColor = .white
        label.isHidden = true

        return label
    }()

    private var isExtraLifeAvailable = true

    // MARK: Initializers

    init(size: CGSize, delegate: GameOverDelegate) {
        self.gameOverDelegate = delegate

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

        backgroundColor = UIColor(asset: Assets.Colors.spaceBackground)!
        backgroundStarsNode.setScale(1.2)
        backgroundStarsNode.blendMode = .screen
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
        camera.addChild(currentBestLabel)
        self.camera = camera

        addChild(backgroundStarsNode)
        addChild(camera)

        entityCoordinator.addEntity(player, to: .player)
        setEntityNodePosition(entity: player, position: CGPoint(x: 0.0, y: -size.height * 0.3))
        entityCoordinator.addEntity(upperAsteroidBelt, to: .interactable)
        setEntityNodePosition(entity: upperAsteroidBelt,
                              position: CGPoint(x: GameplayConfiguration.AsteroidBelt
                                  .positionScreenWidthMultiplier * size.width,
                                  y: 0.0))
        entityCoordinator.addEntity(lowerAsteroidBelt, to: .interactable)
        setEntityNodePosition(entity: lowerAsteroidBelt,
                              position: CGPoint(x: -GameplayConfiguration.AsteroidBelt
                                  .positionScreenWidthMultiplier * size.width,
                                  y: -lowerAsteroidBelt.renderComponent.node.size.height))

        player.physicsComponent.physicsBody.applyImpulse(CGVector(dx: 0, dy: 20))

        stateMachine.enter(GameSceneActiveState.self)

        setCameraConstraints()

        view.addSubview(resumeLabel)

        resumeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.snp.bottomMargin).offset(-50)
        }

        #if DEBUG
            view.showsPhysics = true
        #endif
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        let referencePoint = player.renderComponent.node.position

        guard let nearestPlanet = player.orbitalComponent
            .nearestGravitationalComponent(in: entityCoordinator,
                                           to: referencePoint) else { return }

        nearestPlanetPosition = nearestPlanet.renderComponent.node.position
        nearestPlanetSize = nearestPlanet.renderComponent.node.size.width
        isInOrbit = true
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        isInOrbit = false
        if stateMachine.currentState is GameScenePauseState {
            resumeGame()
        }
    }

    func didBegin(_: SKPhysicsContact) {
        stateMachine.enter(GameSceneOverlayState.self)
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
        upperAsteroidBelt.renderComponent.node.position.y += GameplayConfiguration.AsteroidBelt.speed * deltaTime
        lowerAsteroidBelt.renderComponent.node.position.y += GameplayConfiguration.AsteroidBelt.speed * deltaTime
        if upperAsteroidBelt.renderComponent.node.frame.maxY < camera!.frame.minY - size.height / 2 {
            upperAsteroidBelt.renderComponent.node.position.y += 2 * upperAsteroidBelt.renderComponent.node.size.height
        }
        if lowerAsteroidBelt.renderComponent.node.frame.maxY < camera!.frame.minY - size.height / 2 {
            lowerAsteroidBelt.renderComponent.node.position.y += 2 * lowerAsteroidBelt.renderComponent.node.size.height
        }

        if camera!.frame.midX > 0 {
            let xPosition = GameplayConfiguration.AsteroidBelt.positionScreenWidthMultiplier * size.width
            upperAsteroidBelt.renderComponent.node.position.x = xPosition
            lowerAsteroidBelt.renderComponent.node.position.x = xPosition
        } else {
            let xPosition = -GameplayConfiguration.AsteroidBelt.positionScreenWidthMultiplier * size.width
            upperAsteroidBelt.renderComponent.node.position.x = xPosition
            lowerAsteroidBelt.renderComponent.node.position.x = xPosition
        }

        if topY - player.renderComponent.node.position.y < GameplayConfiguration.Planet.planetSpawnDistance {
            spawnPlanet()
        }

        if isInOrbit {
            let direction = nearestPlanetPosition - player.renderComponent.node.position
            let velocity = player.physicsComponent.physicsBody.velocity
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
            if player.physicsComponent.physicsBody.velocity == .zero {
                // FIXME: Temporary solution
                if stateMachine.currentState is GameSceneActiveState, isExtraLifeAvailable {
                    stateMachine.enter(GameSceneNewGameState.self)
                }
            }
        }

        let currentY = player.renderComponent.node.position.y
        if currentY > maxY {
            maxY = currentY
        }

        score = Score(value: Int(maxY / 100))

        if score > currentBest {
            currentBest = score
        }
    }

    // MARK: Level Construction

    func resetPlayer() {
        player.becomeInvincible(for: GameplayConfiguration.Player.extraLifeInvincibilityDuration)

        player.physicsComponent.updateColliderType(.none)
        player.physicsComponent.physicsBody.velocity = .zero
        player.physicsComponent.physicsBody.angularVelocity = .zero
        setEntityNodePosition(entity: player, position: CGPoint(x: 0.0, y: player.renderComponent.node.position.y))
        player.physicsComponent.physicsBody.applyImpulse(CGVector(dx: 0, dy: 20))
    }

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
        let asteroidPosition = GameplayConfiguration.AsteroidBelt.positionScreenWidthMultiplier
        let xCoordinateInterval: ClosedRange<CGFloat> = -asteroidPosition...asteroidPosition
        var xCoordinate = CGFloat.random(in: xCoordinateInterval) * GameplayConfiguration.Planet
            .asteroidPositionMultiplier
        if isFirstPlanet {
            isFirstPlanet = false
            let invalidRange = GameplayConfiguration.Planet.invalidInitialRange
            let newPosition = { CGFloat.random(in: GameplayConfiguration.Planet.validInitialRange) }
            xCoordinate = newPosition()
            while invalidRange.contains(xCoordinate) {
                xCoordinate = newPosition()
            }
        }
        xCoordinate *= size.width

        let initialPosition: SIMD2<Float> = .init(x: Float(xCoordinate),
                                                  y: Float(camera!.frame.maxY + view!.frame.height))
        let newPlanet = Planet(imageName: PlanetAssets.allImages.randomElement()!.name,
                               initialPosition: initialPosition)
        setEntityNodePosition(entity: newPlanet, position: CGPoint(x: initialPosition.x, y: initialPosition.y))

        entityCoordinator.addEntity(newPlanet, to: .interactable)

        topY += CGFloat.random(in: 150...300)
    }

    private func setEntityNodePosition(entity: GKEntity, position: CGPoint) {
        guard let renderComponent = entity.component(ofType: RenderComponent.self) else { return }

        renderComponent.node.position = position
    }

    // MARK: Convenience

    func gameOverHandlingDidFinish() {
        stateMachine.enter(GameSceneNewGameState.self)
    }

    func startNewGame() {
        let newScene = GameScene(size: size, delegate: gameOverDelegate)
        newScene.scaleMode = scaleMode
        let animation = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(newScene, transition: animation)
    }

    func submitScore() async {
        try? await GKLeaderboard.submitScore(score.value, context: 0, player: GKLocalPlayer.local,
                                             leaderboardIDs: ["AllTimeBests"])
        highScoreStore.tryToUpdateHighScore(with: score)
        currentBest = highScoreStore.fetchHighScore()
    }

    func continueWithExtraLife() {
        stateMachine.enter(GameSceneActiveState.self)
    }

    @objc func extraLifeReward() {
        if isExtraLifeAvailable {
            gameOverDelegate.presentRewardedAd()
            isExtraLifeAvailable = false
        } else {
            gameOverDelegate.presentLimitExceededAlert()
        }
    }

    @objc func playAgain() {
        stateMachine.enter(GameSceneGameOverState.self)
    }

    @objc func leaderboard() {
        gameOverDelegate.presentLeaderboard()
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
