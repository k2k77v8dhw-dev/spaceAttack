import Testing
@testable import SpaceAttack

@Test func maneuverClampsPlayerInsideArena() {
    var game = GameState(arenaSize: Vector2D(x: 100, y: 100), player: PlayerShip(position: Vector2D(x: 50, y: 50)))

    game.maneuverPlayer(dx: 80, dy: -100)

    #expect(game.player.position == Vector2D(x: 100, y: 0))
}

@Test func asteroidCollisionDamagesPlayer() {
    var game = GameState(arenaSize: Vector2D(x: 100, y: 100), player: PlayerShip(position: Vector2D(x: 20, y: 20), health: 100))
    game.addAsteroid(Asteroid(position: Vector2D(x: 20, y: 20), velocity: Vector2D(x: 0, y: 0)))

    game.update(deltaTime: 0.1)

    #expect(game.player.health == 80)
    #expect(game.asteroids.isEmpty)
}

@Test func projectileDestroysEnemyAndScores() {
    var game = GameState(arenaSize: Vector2D(x: 400, y: 200), player: PlayerShip(position: Vector2D(x: 50, y: 50)))
    game.addEnemyShip(EnemyShip(position: Vector2D(x: 130, y: 50), velocity: Vector2D(x: 0, y: 0)))
    game.fireProjectile(speed: 800)

    game.update(deltaTime: 0.1)

    #expect(game.enemies.isEmpty)
    #expect(game.score == 100)
}

@Test func inboundAsteroidPastRightEdgeIsNotRemovedBeforeEnteringArena() {
    var game = GameState(arenaSize: Vector2D(x: 400, y: 200), player: PlayerShip(position: Vector2D(x: 50, y: 50)))
    game.addAsteroid(Asteroid(position: Vector2D(x: 470, y: 100), velocity: Vector2D(x: -150, y: 0)))

    game.update(deltaTime: 0.1)

    #expect(game.asteroids.count == 1)
    #expect(game.asteroids[0].position.x == 455)
}

@Test func inboundEnemyPastRightEdgeIsNotRemovedBeforeEnteringArena() {
    var game = GameState(arenaSize: Vector2D(x: 400, y: 200), player: PlayerShip(position: Vector2D(x: 50, y: 50)))
    game.addEnemyShip(EnemyShip(position: Vector2D(x: 490, y: 100), velocity: Vector2D(x: -120, y: 0)))

    game.update(deltaTime: 0.1)

    #expect(game.enemies.count == 1)
    #expect(game.enemies[0].position.x == 478)
}

@Test func shipOrientationControlsProjectileDirection() {
    var game = GameState(arenaSize: Vector2D(x: 200, y: 200), player: PlayerShip(position: Vector2D(x: 50, y: 50)))

    game.maneuverPlayer(dx: 0, dy: 20)
    game.fireProjectile(speed: 100)

    #expect(abs(game.player.facingAngle - (.pi / 2)) < 0.0001)
    #expect(abs(game.projectiles[0].velocity.x) < 0.0001)
    #expect(abs(game.projectiles[0].velocity.y - 100) < 0.0001)
}
