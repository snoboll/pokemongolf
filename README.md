# Pokemon Golf

Pokemon Golf is a Flutter MVP where every hole on the course triggers a Pokemon
encounter. Your score on that hole directly affects the catch rate, while the
Pokemon's rarity pushes that rate back down.

## Game Loop

1. Start a 9-hole or 18-hole round.
2. Encounter one Pokemon on each hole.
3. Pick your result for that hole, from albatross through triple bogey or worse.
4. Resolve a catch attempt using score bonus plus rarity penalty.
5. Review your collection progress and completed round history.

## Rarity Rules

- `Common`: most frequent and easiest to catch
- `Rare`: less frequent with a moderate catch penalty
- `Epic`: uncommon and noticeably tougher to catch
- `Legendary`: rarest encounters and hardest catches

The first 151 Pokemon are included in the local catalog for this version.

## Image Source

Pokemon art is loaded at runtime from the HybridShivam image set:

- Source browser: `https://github.com/HybridShivam/Pokemon/tree/master/assets/images`
- Runtime format: `https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/001.png`

The app builds image URLs from 3-digit dex numbers such as `001` through `151`.

## Running The App

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter analyze
flutter test
```
# pokemongolf
