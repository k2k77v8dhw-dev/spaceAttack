# spaceAttack

Minimal iOS 2D space game scaffold built with Swift + SpriteKit.

## Gameplay included
- A controllable spaceship that rotates in any direction while maneuvering around the arena
- An endless stream of moving asteroids that damage the player on collision
- Enemy ships that keep arriving from the right side of the arena
- Player projectiles fired from a dedicated on-screen button to defend against enemy ships and score points

## Project structure
- `Sources/SpaceAttack/SpaceAttack.swift` – core gameplay model and collision/update logic
- `Sources/SpaceAttack/SpaceAttackIOS.swift` – iOS SpriteKit scene + SwiftUI app entrypoint
- `Tests/SpaceAttackTests/SpaceAttackTests.swift` – focused tests for maneuvering, asteroid damage, and enemy defense

## Run tests
```bash
swift test
```

## Run on iOS
You can now open either setup in Xcode on macOS:

- `Package.swift` for the Swift Package workflow.
- `SpaceAttack.xcodeproj` for a standard Xcode iOS app project.

For the Xcode project, choose an iOS simulator and run the `SpaceAttack` target.

The iOS app is configured for landscape-only play.
