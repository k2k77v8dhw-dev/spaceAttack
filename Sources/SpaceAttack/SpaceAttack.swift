import Foundation

public struct Vector2D: Equatable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    func distance(to other: Vector2D) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return (dx * dx + dy * dy).squareRoot()
    }
}

public struct PlayerShip: Equatable {
    public var position: Vector2D
    public var health: Int
    public var facingAngle: Double

    public init(position: Vector2D, health: Int = 100, facingAngle: Double = 0) {
        self.position = position
        self.health = health
        self.facingAngle = facingAngle
    }
}

public struct Asteroid: Equatable {
    public var id: UUID
    public var position: Vector2D
    public var velocity: Vector2D

    public init(id: UUID = UUID(), position: Vector2D, velocity: Vector2D) {
        self.id = id
        self.position = position
        self.velocity = velocity
    }
}

public struct EnemyShip: Equatable {
    public var id: UUID
    public var position: Vector2D
    public var velocity: Vector2D

    public init(id: UUID = UUID(), position: Vector2D, velocity: Vector2D) {
        self.id = id
        self.position = position
        self.velocity = velocity
    }
}

public struct Projectile: Equatable {
    public var id: UUID
    public var position: Vector2D
    public var velocity: Vector2D

    public init(id: UUID = UUID(), position: Vector2D, velocity: Vector2D) {
        self.id = id
        self.position = position
        self.velocity = velocity
    }
}

public struct GameState {
    public private(set) var arenaSize: Vector2D
    public private(set) var player: PlayerShip
    public private(set) var asteroids: [Asteroid]
    public private(set) var enemies: [EnemyShip]
    public private(set) var projectiles: [Projectile]
    public private(set) var score: Int

    public init(arenaSize: Vector2D = Vector2D(x: 1024, y: 768), player: PlayerShip? = nil) {
        self.arenaSize = arenaSize
        self.player = player ?? PlayerShip(position: Vector2D(x: arenaSize.x * 0.2, y: arenaSize.y * 0.5))
        self.asteroids = []
        self.enemies = []
        self.projectiles = []
        self.score = 0
    }

    public mutating func maneuverPlayer(dx: Double, dy: Double) {
        let nextX = min(max(player.position.x + dx, 0), arenaSize.x)
        let nextY = min(max(player.position.y + dy, 0), arenaSize.y)
        player.position = Vector2D(x: nextX, y: nextY)
        if dx != 0 || dy != 0 {
            player.facingAngle = atan2(dy, dx)
        }
    }

    public mutating func aimPlayer(toward target: Vector2D) {
        let dx = target.x - player.position.x
        let dy = target.y - player.position.y
        guard dx != 0 || dy != 0 else { return }
        player.facingAngle = atan2(dy, dx)
    }

    public mutating func addAsteroid(_ asteroid: Asteroid) {
        asteroids.append(asteroid)
    }

    public mutating func addEnemyShip(_ enemy: EnemyShip) {
        enemies.append(enemy)
    }

    public mutating func fireProjectile(speed: Double = 500) {
        let projectile = Projectile(
            position: player.position,
            velocity: Vector2D(
                x: cos(player.facingAngle) * speed,
                y: sin(player.facingAngle) * speed
            )
        )
        projectiles.append(projectile)
    }

    public mutating func update(deltaTime: Double) {
        guard deltaTime > 0 else { return }

        for index in asteroids.indices {
            asteroids[index].position.x += asteroids[index].velocity.x * deltaTime
            asteroids[index].position.y += asteroids[index].velocity.y * deltaTime
        }

        for index in enemies.indices {
            enemies[index].position.x += enemies[index].velocity.x * deltaTime
            enemies[index].position.y += enemies[index].velocity.y * deltaTime
        }

        for index in projectiles.indices {
            projectiles[index].position.x += projectiles[index].velocity.x * deltaTime
            projectiles[index].position.y += projectiles[index].velocity.y * deltaTime
        }

        asteroids.removeAll { asteroid in
            asteroid.position.x < -50 || asteroid.position.x > arenaSize.x + 50 ||
            asteroid.position.y < -50 || asteroid.position.y > arenaSize.y + 50
        }

        enemies.removeAll { enemy in
            enemy.position.x < -50 || enemy.position.x > arenaSize.x + 50 ||
            enemy.position.y < -50 || enemy.position.y > arenaSize.y + 50
        }

        projectiles.removeAll { projectile in
            projectile.position.x < -50 || projectile.position.x > arenaSize.x + 50 ||
            projectile.position.y < -50 || projectile.position.y > arenaSize.y + 50
        }

        resolveCollisions()
    }

    private mutating func resolveCollisions() {
        asteroids.removeAll { asteroid in
            let didHitPlayer = asteroid.position.distance(to: player.position) <= 28
            if didHitPlayer {
                player.health = max(0, player.health - 20)
            }
            return didHitPlayer
        }

        enemies.removeAll { enemy in
            let didHitPlayer = enemy.position.distance(to: player.position) <= 30
            if didHitPlayer {
                player.health = max(0, player.health - 30)
            }
            return didHitPlayer
        }

        var projectileIDsToRemove = Set<UUID>()
        var enemyIDsToRemove = Set<UUID>()

        for projectile in projectiles {
            for enemy in enemies where !enemyIDsToRemove.contains(enemy.id) {
                if projectile.position.distance(to: enemy.position) <= 24 {
                    projectileIDsToRemove.insert(projectile.id)
                    enemyIDsToRemove.insert(enemy.id)
                    score += 100
                    break
                }
            }
        }

        if !projectileIDsToRemove.isEmpty {
            projectiles.removeAll { projectileIDsToRemove.contains($0.id) }
        }

        if !enemyIDsToRemove.isEmpty {
            enemies.removeAll { enemyIDsToRemove.contains($0.id) }
        }
    }
}
