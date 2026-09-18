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
