//
//  GameScene.swift
//  Marbles
//
//  Created by Suresh Thotakura on 22/04/2020.
//  Copyright © 2020 Neharjun Technologies Limited. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class Ball : SKSpriteNode {
    
    static let DefaultRadius = CGFloat(20)
    static let DefaultSize = CGSize(width: Ball.DefaultRadius * 2, height: Ball.DefaultRadius * 2)
    
}

class GameScene: SKScene {
    
    let balls = ["blue", "gray", "green", "red", "yellow"]
    let resetButton = SKSpriteNode(imageNamed: "reset")

    let gameSounds = GameSounds.shared
    
    var matchedBalls = Set<Ball>()
    
    var scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            scoreLabel.position = CGPoint(x: frame.minX + scoreLabel.frame.size.width / 2 + 10, y: frame.minY + scoreLabel.frame.size.height)
        }
    }
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let position = touches.first?.location(in: self) else { return }

        if ((nodes(at: position).first(where: {$0.name == "reset"}) as? SKSpriteNode) != nil) {
            resetScene()
            return
        }

        guard let tappedBall = nodes(at: position).first(where: {$0 is Ball }) as? Ball else { return }
        
        matchedBalls.removeAll(keepingCapacity: true)
        
        getMatches(from: tappedBall)
        
        if matchedBalls.count >= 3 {
            score += Int(pow(2, Double(min(matchedBalls.count, 16))))

            for ball in matchedBalls {
                if let particles = SKEmitterNode(fileNamed: "Explosion"){
                    particles.position = ball.position
                    addChild(particles)
                    
                    let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
                    particles.run(removeAfterDead)
                }
                let removeSequence = SKAction.sequence([gameSounds.blop, SKAction.removeFromParent()])
                ball.run(removeSequence)
            }
            
            if matchedBalls.count > 5 {
                let wow = SKSpriteNode(imageNamed: "wow!")
                wow.position = CGPoint(x: frame.midX, y: frame.midY)
                wow.zPosition = 100
                wow.xScale = 0.001
                wow.yScale = 0.001
                addChild(wow)

                let appear = SKAction.group([SKAction.scale(to: 1, duration: 0.25), SKAction.fadeIn(withDuration: 0.25)])
                let disappear = SKAction.group([SKAction.scale(to: 2, duration: 0.25), SKAction.fadeOut(withDuration: 0.25)])
                let sequence = SKAction.sequence([appear, SKAction.wait(forDuration: 0.25), disappear, SKAction.removeFromParent()])
                wow.run(sequence)
            }
        }
    }
    
    fileprivate func addBalls() {
        let ballRadius = Ball.DefaultRadius
        
        for i in stride(from: ballRadius, to: frame.width - ballRadius, by: ballRadius * 2) {
            for j in stride(from: 100, to: frame.height - ballRadius, by: ballRadius * 2) {
                let ballType = balls.randomElement()!
                let ball = Ball(imageNamed: ballType)
                ball.size = Ball.DefaultSize
                ball.position = CGPoint(x: i, y: j)
                ball.name = ballType
                ball.physicsBody = SKPhysicsBody(circleOfRadius: Ball.DefaultRadius)
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.restitution = 0
                ball.physicsBody?.friction = 0
                addChild(ball)
            }
        }
    }
    
    fileprivate func addScoreLabel() {
        scoreLabel.fontSize = 42
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
    }
    
    fileprivate func addResetButton() {
        resetButton.position = CGPoint(x: 20, y: frame.maxY - 20)
        resetButton.name = "reset"
        resetButton.zPosition = 100
        addChild(resetButton)
    }
    
    func setupScene() {
        addBalls()

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)))
        
        addScoreLabel()
        addResetButton()
        
        score = 0
    }
    
    fileprivate func resetScene() {
        removeAllChildren()
        setupScene()
    }
    
    func getMatches(from startBall: Ball) {
        let matchWidth = startBall.frame.width * startBall.frame.width * 1.1

        for node in children {
            guard let ball = node as? Ball else { continue }
            guard ball.name == startBall.name else { continue }

            let dist = distance(from: startBall, to: ball)

            guard dist < matchWidth else { continue }

            if !matchedBalls.contains(ball) {
                matchedBalls.insert(ball)
                getMatches(from: ball)
            }
        }
    }

    // This is Pythagoras's Theorem: https://en.wikipedia.org/wiki/Pythagorean_theorem
    func distance(from: Ball, to: Ball) -> CGFloat {
        return (from.position.x - to.position.x) * (from.position.x - to.position.x) + (from.position.y - to.position.y) * (from.position.y - to.position.y)
    }
}
