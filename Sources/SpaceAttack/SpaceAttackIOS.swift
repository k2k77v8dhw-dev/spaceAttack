#if os(iOS)
import SpriteKit
import SwiftUI

public final class SpaceAttackScene: SKScene {
    private var gameState = GameState(arenaSize: Vector2D(x: 1024, y: 768))
    private let playerNode = SKShapeNode(path: SpaceAttackScene.playerShipPath())
    private var lastUpdateTime: TimeInterval?
    private var asteroidSpawnCountdown = 0.0
    private var enemySpawnCountdown = 0.0

    private static func playerShipPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 20, y: 0))
        path.addLine(to: CGPoint(x: -14, y: 12))
        path.addLine(to: CGPoint(x: -8, y: 0))
        path.addLine(to: CGPoint(x: -14, y: -12))
        path.closeSubpath()
        return path
    }

    public override func didMove(to view: SKView) {
        backgroundColor = .black
        scaleMode = .resizeFill

        playerNode.fillColor = .cyan
        playerNode.strokeColor = .white
        addChild(playerNode)

        seedInitialWave()
        resetSpawnCountdowns()

        renderState()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePlayerControl(with: touch)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updatePlayerControl(with: touch)
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

        if gameState.player.health <= 0 {
            renderState()
            isPaused = true
            return
        }

        updateSpawns(deltaTime: deltaTime)
        renderState()
    }

    public func fireProjectile() {
        guard gameState.player.health > 0 else { return }
        gameState.fireProjectile()
        renderState()
    }

    private func renderState() {
        playerNode.position = CGPoint(x: gameState.player.position.x, y: gameState.player.position.y)
        playerNode.zRotation = gameState.player.facingAngle

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

    private func updatePlayerControl(with touch: UITouch) {
        let location = touch.location(in: self)
        let target = Vector2D(x: Double(location.x), y: Double(location.y))
        let dx = target.x - gameState.player.position.x
        let dy = target.y - gameState.player.position.y
        gameState.aimPlayer(toward: target)
        gameState.maneuverPlayer(dx: dx * 0.18, dy: dy * 0.18)
        renderState()
    }

    private func seedInitialWave() {
        for offset in 0..<4 {
            spawnAsteroid(xOffset: Double(offset) * 180)
        }

        for offset in 0..<2 {
            spawnEnemy(xOffset: 180 + Double(offset) * 260)
        }
    }

    private func resetSpawnCountdowns() {
        asteroidSpawnCountdown = Double.random(in: 0.4...0.9)
        enemySpawnCountdown = Double.random(in: 1.6...2.4)
    }

    private func updateSpawns(deltaTime: Double) {
        asteroidSpawnCountdown -= deltaTime
        enemySpawnCountdown -= deltaTime

        while asteroidSpawnCountdown <= 0 {
            spawnAsteroid()
            asteroidSpawnCountdown += Double.random(in: 0.55...1.0)
        }

        while enemySpawnCountdown <= 0 {
            spawnEnemy()
            enemySpawnCountdown += Double.random(in: 1.8...3.0)
        }
    }

    private func spawnAsteroid(xOffset: Double = 0) {
        let asteroid = Asteroid(
            position: Vector2D(
                x: gameState.arenaSize.x + 70 + xOffset,
                y: Double.random(in: 70...(gameState.arenaSize.y - 70))
            ),
            velocity: Vector2D(
                x: Double.random(in: -220 ... -130),
                y: Double.random(in: -60...60)
            )
        )
        gameState.addAsteroid(asteroid)
    }

    private func spawnEnemy(xOffset: Double = 0) {
        let enemy = EnemyShip(
            position: Vector2D(
                x: gameState.arenaSize.x + 90 + xOffset,
                y: Double.random(in: 100...(gameState.arenaSize.y - 100))
            ),
            velocity: Vector2D(
                x: Double.random(in: -160 ... -110),
                y: Double.random(in: -30...30)
            )
        )
        gameState.addEnemyShip(enemy)
    }
}

public struct SpaceAttackGameView: View {
    private let scene: SpaceAttackScene

    public init() {
        let scene = SpaceAttackScene(size: CGSize(width: 1024, height: 768))
        scene.anchorPoint = CGPoint(x: 0, y: 0)
        self.scene = scene
    }

    public var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .overlay(alignment: .bottomTrailing) {
                    Button(action: scene.fireProjectile) {
                        Image(systemName: "scope")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 74, height: 74)
                            .background(.black.opacity(0.55), in: Circle())
                            .overlay {
                                Circle()
                                    .stroke(.cyan.opacity(0.9), lineWidth: 2)
                            }
                    }
                    .padding(.trailing, max(24, geometry.size.width * 0.04))
                    .padding(.bottom, max(24, geometry.size.height * 0.06))
                }
        }
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
