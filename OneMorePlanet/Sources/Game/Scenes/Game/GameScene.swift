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

    private lazy var player: Player = {
        let player = Player(imageName: Assets.Images.alien.name)

        let emitter = SKEmitterNode(fileNamed: "BokehParticles")!
        player.renderComponent.node.addChild(emitter)
        emitter.targetNode = self

        return player
    }()

    private lazy var arrow: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: Assets.Images.arrow.name)

        return node
    }()

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

    private var nearestPlanetPosition: CGPoint = .zero

    private var isFirstPlanet: Bool = true

    private lazy var topY: CGFloat = GameplayConfiguration.Planet.planetSpawnDistance

    private var maxY: CGFloat = 0

    private let backgroundStars: [Star] = {
        var stars = [Star]()

        for i in 0..<GameplayConfiguration.Star.backgroundStarsCount {
            let star = Star(distance: .random())
            stars.append(star)
        }

        return stars
    }()

    private(set) var score: Score = .zero {
        didSet {
            scoreLabel.text = "\(score.value)"
        }
    }

    private var lastPlayerPosition = CGPoint()

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

    private let filledHeart = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.red)
    private let emptyHeart = UIImage(systemName: "heart")?.withRenderingMode(.alwaysOriginal).withTintColor(.red)

    private lazy var lifesIndicator: UIStackView = {
        let stack = UIStackView()

        stack.axis = .horizontal
        stack.alignment = .center

        return stack
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

    private let initialImpulse = CGVector(dx: 0, dy: 35)

    // MARK: Initializers

    init(size: CGSize, delegate: GameOverDelegate) {
        self.gameOverDelegate = delegate

        super.init(size: size)

        backgroundColor = UIColor(asset: Assets.Colors.spaceBackground)!

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        registerForPauseNotifications()

        addWorldLayers()

        setupCamera()

        setupEntities()

        setupChildren()

        setCameraConstraints()
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

        stateMachine.enter(GameSceneActiveState.self)

        setupSubviews()

        updateLifesIndicator()

        #if DEBUG
            view.showsPhysics = true
        #endif
    }

    private func setupCamera() {
        let camera = SKCameraNode()
        camera.addChild(scoreLabel)
        camera.addChild(currentBestLabel)
        self.camera = camera
        addChild(camera)
    }

    private func setupEntities() {
        backgroundStars.forEach {
            entityCoordinator.addEntity($0, to: .stars)
            let randomX = CGFloat
                .random(in: -GameplayConfiguration.Scene.halfWidth...GameplayConfiguration.Scene.halfWidth)
            let randomY = CGFloat
                .random(in: -GameplayConfiguration.Scene.halfHeight...GameplayConfiguration.Scene.halfHeight)
            setEntityNodePosition(entity: $0, position: CGPoint(x: randomX, y: randomY))
        }
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

        player.physicsComponent.physicsBody.applyImpulse(initialImpulse)
    }

    private func setupChildren() {
        let initialPoint = CGPoint(x: 0, y: GameplayConfiguration.Scene.height)
        arrow.position = initialPoint
        addChild(arrow)

        let lookAtConstraint = SKConstraint.orient(to: initialPoint,
                                                   offset: SKRange(constantValue: -.pi / 2))
        let playerNode = player.renderComponent.node
        let playerLocationConstraint = SKConstraint
            .distance(SKRange(constantValue: player.renderComponent.node.size.width * 0.6),
                      to: playerNode)
        arrow.constraints = [lookAtConstraint, playerLocationConstraint]
    }

    private func setupSubviews() {
        view!.addSubview(resumeLabel)

        resumeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view!.snp.bottomMargin).offset(-50)
        }

        view!.addSubview(lifesIndicator)

        lifesIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.trailing.equalToSuperview().inset(20)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        let referencePoint = player.renderComponent.node.position

        guard let nearestPlanet = player.orbitalComponent
            .nearestGravitationalComponent(in: entityCoordinator,
                                           to: referencePoint) else { return }

        nearestPlanetPosition = nearestPlanet.renderComponent.node.position
        arrow.isHidden = true
        isInOrbit = true
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        arrow.isHidden = false
        isInOrbit = false
        if stateMachine.currentState is GameScenePauseState {
            resumeGame()
        }
    }

    func didBegin(_: SKPhysicsContact) {
        if player.lifeComponent.numberOfLives >= 1 {
            player.becomeInvincible(for: GameplayConfiguration.Player.collisionInvincibilityDuration)
            player.lifeComponent.takeLife()
        }
        updateLifesIndicator()
        if !player.lifeComponent.isAlive {
            stateMachine.enter(GameSceneOverlayState.self)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        guard view != nil else { return }

        var deltaTime = currentTime - lastUpdateTimeInterval

        deltaTime = deltaTime > maxUpdateTimeInterval ? maxUpdateTimeInterval : deltaTime

        lastUpdateTimeInterval = currentTime

        if isReallyPaused { return }

        stateMachine.update(deltaTime: deltaTime)

        updateAsteroidBelts(deltaTime: deltaTime)

        if let nextPlanet = player.orbitalComponent
            .nearestGravitationalComponent(in: entityCoordinator,
                                           to: player.renderComponent.node.position) {
            let nextPlanetPosition = nextPlanet.renderComponent.node.position
            let lookAtConstraint = SKConstraint.orient(to: nextPlanetPosition, offset: SKRange(constantValue: -.pi / 2))
            arrow.constraints![0] = lookAtConstraint
            arrow.position = nextPlanetPosition
        }

        if topY - player.renderComponent.node.position.y < GameplayConfiguration.Planet.planetSpawnDistance {
            spawnPlanet()
        }

        updatePlayer(deltaTime: deltaTime)

        updateBackgroundStars()

        let currentY = player.renderComponent.node.position.y
        if currentY > maxY {
            maxY = currentY
        }

        score = Score(value: Int(maxY / 100))

        if score > currentBest {
            currentBest = score
        }
    }

    private func updateAsteroidBelts(deltaTime: TimeInterval) {
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
    }

    private func updatePlayer(deltaTime: TimeInterval) {
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
            let attractionForce = deltaTime * 12.5 * velocityLength * normalizedDirection
            player.physicsComponent.physicsBody.applyForce(CGVector(dx: attractionForce.x, dy: attractionForce.y))
            let normalizedVelocity = 15 * (velocityPoint / velocityLength)
            player.physicsComponent.physicsBody.applyForce(CGVector(dx: normalizedVelocity.x, dy: normalizedVelocity.y))
        } else {
            if player.physicsComponent.physicsBody.velocity == .zero {
                if stateMachine.currentState is GameSceneActiveState {
                    stateMachine.enter(GameSceneOverlayState.self)
                }
            }
        }
    }

    private func updateBackgroundStars() {
        let currentPlayerPosition = player.renderComponent.node.position
        let dx = lastPlayerPosition.x - currentPlayerPosition.x
        let dy = lastPlayerPosition.y - currentPlayerPosition.y
        let displacement = CGPoint(x: dx, y: dy)

        backgroundStars.forEach {
            $0.movementComponent.updatePosition(displacement: displacement,
                                                referencePoint: currentPlayerPosition,
                                                factor: $0.displacementFactor)
        }

        lastPlayerPosition = currentPlayerPosition
    }

    // MARK: Level Construction

    func resetPlayer() {
        player.becomeInvincible(for: GameplayConfiguration.Player.extraLifeInvincibilityDuration)

        player.physicsComponent.updateColliderType(.none)
        player.physicsComponent.physicsBody.velocity = .zero
        player.physicsComponent.physicsBody.angularVelocity = .zero
        setEntityNodePosition(entity: player, position: CGPoint(x: 0.0, y: player.renderComponent.node.position.y))
        player.physicsComponent.physicsBody.applyImpulse(initialImpulse)
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

    private func updateLifesIndicator() {
        for view in lifesIndicator.arrangedSubviews {
            view.removeFromSuperview()
        }

        let lifesLost = player.lifeComponent.maximumLives - player.lifeComponent.numberOfLives

        for _ in 0..<lifesLost {
            lifesIndicator.addArrangedSubview(UIImageView(image: emptyHeart))
        }

        for _ in 0..<player.lifeComponent.numberOfLives {
            lifesIndicator.addArrangedSubview(UIImageView(image: filledHeart))
        }

        lifesIndicator.layoutSubviews()
    }

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

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.highScoreStore.tryToUpdateHighScore(with: self.score)
            self.currentBest = self.highScoreStore.fetchHighScore()
        }
    }

    func continueWithExtraLife() {
        player.lifeComponent.awardLifes(GameplayConfiguration.Player.maximumLives - 1)
        updateLifesIndicator()
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
