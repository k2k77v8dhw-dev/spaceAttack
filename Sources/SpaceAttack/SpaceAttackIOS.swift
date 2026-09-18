#if os(iOS)
import SpriteKit
import SwiftUI

public final class SpaceAttackScene: SKScene {
    private var gameState = GameState(arenaSize: Vector2D(x: 1024, y: 768))
    private let playerNode = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -16, y: -16, width: 32, height: 32), transform: nil))
    private var lastUpdateTime: TimeInterval?

    public override func didMove(to view: SKView) {
        backgroundColor = .black
        scaleMode = .resizeFill

        playerNode.fillColor = .cyan
        playerNode.strokeColor = .white
        addChild(playerNode)

        for row in 0..<5 {
            let asteroid = Asteroid(
                position: Vector2D(x: 1024 + Double(row * 180), y: Double(Int.random(in: 80...680))),
                velocity: Vector2D(x: Double(Int.random(in: -180 ... -120)), y: Double(Int.random(in: -40...40)))
            )
            gameState.addAsteroid(asteroid)
        }

        for row in 0..<3 {
            let enemy = EnemyShip(
                position: Vector2D(x: 800 + Double(row * 250), y: Double(Int.random(in: 120...640))),
                velocity: Vector2D(x: -120, y: 0)
            )
            gameState.addEnemyShip(enemy)
        }

        renderState()
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let dx = Double(location.x) - gameState.player.position.x
        let dy = Double(location.y) - gameState.player.position.y
        gameState.maneuverPlayer(dx: dx * 0.18, dy: dy * 0.18)
        renderState()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameState.fireProjectile()
    }

    public override func update(_ currentTime: TimeInterval) {
        let deltaTime: Double
        if let previous = lastUpdateTime {
            deltaTime = min(currentTime - previous, 1.0 / 30.0)
        } else {
            deltaTime = 1.0 / 60.0
        }
        lastUpdateTime = currentTime

        gameState.update(deltaTime: deltaTime)
        renderState()

        if gameState.player.health <= 0 {
            isPaused = true
        }
    }

    private func renderState() {
        playerNode.position = CGPoint(x: gameState.player.position.x, y: gameState.player.position.y)

        childNode(withName: "asteroids")?.removeFromParent()
        childNode(withName: "enemies")?.removeFromParent()
        childNode(withName: "projectiles")?.removeFromParent()

        let asteroidContainer = SKNode()
        asteroidContainer.name = "asteroids"
        for asteroid in gameState.asteroids {
            let node = SKShapeNode(circleOfRadius: 18)
            node.fillColor = .gray
            node.strokeColor = .lightGray
            node.position = CGPoint(x: asteroid.position.x, y: asteroid.position.y)
            asteroidContainer.addChild(node)
        }

        let enemyContainer = SKNode()
        enemyContainer.name = "enemies"
        for enemy in gameState.enemies {
            let node = SKShapeNode(rectOf: CGSize(width: 30, height: 20), cornerRadius: 4)
            node.fillColor = .red
            node.strokeColor = .orange
            node.position = CGPoint(x: enemy.position.x, y: enemy.position.y)
            enemyContainer.addChild(node)
        }

        let projectileContainer = SKNode()
        projectileContainer.name = "projectiles"
        for projectile in gameState.projectiles {
            let node = SKShapeNode(circleOfRadius: 4)
            node.fillColor = .green
            node.strokeColor = .white
            node.position = CGPoint(x: projectile.position.x, y: projectile.position.y)
            projectileContainer.addChild(node)
        }

        addChild(asteroidContainer)
        addChild(enemyContainer)
        addChild(projectileContainer)
    }
}

public struct SpaceAttackGameView: View {
    public init() {}

    public var body: some View {
        SpriteView(scene: {
            let scene = SpaceAttackScene(size: CGSize(width: 1024, height: 768))
            scene.anchorPoint = CGPoint(x: 0, y: 0)
            return scene
        }())
        .ignoresSafeArea()
    }
}

@main
struct SpaceAttackApp: App {
    var body: some Scene {
        WindowGroup {
            SpaceAttackGameView()
        }
    }
}
#endif
