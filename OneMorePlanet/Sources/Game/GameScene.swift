//
//  GameScene.swift
//  OneMorePlanet
//
//  Created by Vinícius Couto on 27/01/22.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    private var alive = true

    private let backgroundStarsNode = SKSpriteNode(imageNamed: "Images/Stars")
    private lazy var playerNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "Images/alien")
        node.setScale(1.8)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.categoryBitMask = playerCategory
        node.physicsBody?.contactTestBitMask = obstacleCategory
        node.physicsBody?.collisionBitMask = 0
        node.position = CGPoint(x: frame.size.width / 2, y : frame.size.height * 0.25)
        node.zPosition = 0

        return node
    }()

    private let planetNames = ["planet1", "planet21", "planet4", "planet6", "planet7", "planet23", "planet11"]

    private var planetSpawnTimer: Timer!

    private let obstacleCategory: UInt32 = 0x01 << 0
    private let playerCategory: UInt32 = 0x01 << 1

    private var planetsTree: GKQuadtree<SKSpriteNode>!

    private let cameraNode = SKCameraNode()

    private func configure() {
        planetsTree = .init(boundingQuad: GKQuad(quadMin: simd_float2(x: 20, y: 20), quadMax: simd_float2(x: Float(frame.size.width), y: Float(frame.size.height))), minimumCellSize: 10)
        anchorPoint = .zero

//        camera = cameraNode
//        anchorPoint = CGPoint(x: 0.0, y: 0.0)
//        camera?.position = CGPoint(x: 0.5, y: 0.5)
//        addChild(cameraNode)

        planetSpawnTimer = .scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(spawnPlanet), userInfo: nil, repeats: true)

        backgroundColor = UIColor(named: "Colors/SpaceBackground")!

        backgroundStarsNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundStarsNode.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundStarsNode.zPosition = -1

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        addChild(backgroundStarsNode)
        addChild(playerNode)
    }

    override func didMove(to view: SKView) {
        configure()
    }

    @objc private func spawnPlanet() {
        if alive {
            // Create the meteor (the sprite is selected randomly)
            let planet = SKSpriteNode(imageNamed: "Images/" + planetNames[Int.random(in: 0..<planetNames.count)])
            planet.setScale(2.0)

            // Randomly assign its initial position
            let initialPlanetPosition = CGFloat(GKRandomDistribution(lowestValue: Int(planet.size.width) / 2, highestValue: Int(frame.size.width) - Int(planet.size.width) / 2).nextInt())
            planet.position = CGPoint(x: initialPlanetPosition, y: frame.height + planet.size.height)
            let planetQuadNode = planetsTree.add(planet, at: simd_float2(x: Float(planet.position.x), y: Float(planet.position.y)))

            // Physics stuff
            planet.physicsBody = SKPhysicsBody(rectangleOf: planet.size)
            planet.physicsBody?.isDynamic = true
            planet.physicsBody?.categoryBitMask = obstacleCategory
            planet.physicsBody?.contactTestBitMask = playerCategory
            planet.physicsBody?.collisionBitMask = 0

            self.addChild(planet)
            // This actionArray is responsible for moving the meteor to the bottom of the screen, and removing it from self when it is offscreen
            var actionArray = [SKAction]()

            // This determines how long takes the meteor to arrive its destination
            let planetDuration: TimeInterval = 2

            // First move to the bottom until it disappears, then remove it
            actionArray.append(SKAction.move(to: CGPoint(x: initialPlanetPosition, y: -planet.size.height), duration: planetDuration))
            actionArray.append(SKAction.run { [weak self] in
                self?.planetsTree.remove(planet, using: planetQuadNode)
            })
            actionArray.append(SKAction.removeFromParent())
            actionArray.append(SKAction.run { [weak self] in
                if self?.alive == false {
                    self?.gameOver()
                }
            })

            // Run :)
            planet.run(SKAction.sequence(actionArray))
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {

        cameraNode.position = playerNode.position
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }

    // Game Over handler
    private func gameOver() {
        // We dead :(
        alive = false

        // Paint it black cause we mourning
        let darkFilledRect = SKShapeNode(rect: CGRect(origin: .zero, size: self.frame.size))
        darkFilledRect.fillColor = UIColor.black.withAlphaComponent(0.5)
        darkFilledRect.zPosition = 100
        self.addChild(darkFilledRect)

        // Let the player know they are bad at the game
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        gameOverLabel.fontSize = 52
        gameOverLabel.fontColor = UIColor.white
        gameOverLabel.zPosition = 100
        self.addChild(gameOverLabel)

        // Offer a chance of redemption
        let restartLabel = SKLabelNode(text: "TOUCH TO PLAY AGAIN")
        restartLabel.position = CGPoint(x: gameOverLabel.position.x, y: gameOverLabel.position.y - gameOverLabel.fontSize)
        restartLabel.fontSize = 26
        restartLabel.fontColor = UIColor.white
        restartLabel.zPosition = 100
        self.addChild(restartLabel)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }

        let nearestPlanets = planetsTree.elements(in: GKQuad(quadMin: simd_float2(x: Float(playerNode.position.x) - 300.0, y: Float(playerNode.position.y) - 300.0), quadMax: simd_float2(x: Float(playerNode.position.x + 300.0), y: Float(playerNode.position.y + 300.0))))
        print(nearestPlanets.count)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        if !alive {
            alive = true
            planetSpawnTimer.invalidate()
            removeAllChildren()
            configure()
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        alive = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
