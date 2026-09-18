# spaceAttack

Minimal iOS 2D space game scaffold built with Swift + SpriteKit.

## Gameplay included
- A controllable spaceship that maneuvers around the arena
- Moving asteroids that damage the player on collision
- Enemy ships that can collide with the player
- Player projectiles to defend against enemy ships and score points

## Project structure
- `Sources/SpaceAttack/SpaceAttack.swift` – core gameplay model and collision/update logic
- `Sources/SpaceAttack/SpaceAttackIOS.swift` – iOS SpriteKit scene + SwiftUI app entrypoint
- `Tests/SpaceAttackTests/SpaceAttackTests.swift` – focused tests for maneuvering, asteroid damage, and enemy defense

## Run tests
```bash
swift test
```

## Run on iOS
Open the package in Xcode on macOS and run the iOS app target created from `SpaceAttackApp`.
