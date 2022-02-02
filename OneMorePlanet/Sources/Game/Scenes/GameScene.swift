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

    // MARK: Scene Life Cycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Add background
        backgroundColor = UIColor(named: "Colors/SpaceBackground")!
        let backgroundStarsNode = SKSpriteNode(texture: SKTexture(imageNamed: "Images/Stars"))
        backgroundStarsNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundStarsNode.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundStarsNode.zPosition = -1
        addChild(backgroundStarsNode)

        addWorldLayers()
    }

    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    func didBegin(_ contact: SKPhysicsContact) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
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

    private func addWorldLayers() {
        for layer in WorldLayer.allLayers {
            addChild(worldLayerNodes[layer]!)
        }
    }

    func addNode(node: SKNode, toWorldLayer worldLayer: WorldLayer) {
        guard let worldLayerNode = worldLayerNodes[worldLayer] else { return }

        worldLayerNode.addChild(node)
    }
}
