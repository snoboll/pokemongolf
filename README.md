# Pokemon Golf

A Flutter app that combines golf scoring with Pokemon catching. Every hole on the course triggers a random Pokemon encounter, and your golf score determines the catch rate.

## How It Works

1. **Start a round** -- pick a course (or play without one) and choose 9 or 18 holes.
2. **Play each hole** -- select the hole par and your score (eagle, birdie, par, bogey, etc.).
3. **Encounter a Pokemon** -- a random Pokemon appears, weighted by rarity tier.
4. **Catch attempt** -- your golf score drives the catch probability. Better score = higher catch rate.
5. **Build your Pokedex** -- track your collection across all rounds.

## Features

- **23 preset courses** from Skane, Sweden (Orestad, Falsterbo, Barseback, PGA National, and more), plus the ability to add custom courses.
- **Home course** -- set a favorite course for quick access.
- **5 rarity tiers** -- Common, Uncommon, Rare, Epic, and Legendary, each with distinct encounter weights and catch rates.
- **Terrain modifiers** -- toggle one-putt, bunker, water, and rough to boost encounter rates for matching Pokemon types.
- **Legendary streak** -- consecutive par-or-better holes increase your legendary encounter chance.
- **Scorecard history** -- review hole-by-hole results for every completed round.
- **Pokedex** -- browse all 151 Gen 1 Pokemon with caught/uncaught filters and rarity badges.
- **Trainers leaderboard** -- see other players' Pokedex progress and home courses.
- **Cloud sync** -- Supabase-powered authentication and persistence across devices.

## Rarity & Catch Rates

| Tier | Encounter Weight | Par catch % | Bogey | Double Bogey | Triple+ |
|------|-----------------|-------------|-------|--------------|---------|
| Common | 35% | 100% | 65% | 20% | 5% |
| Uncommon | 25% | 95% | 50% | 12% | 3% |
| Rare | 20% | 90% | 40% | 5% | 2% |
| Epic | 14% | 70% | 25% | 3% | 1% |
| Legendary | 6% | 40% | 10% | 1% | 0% |

Scoring eagle or better always gives 100% catch rate regardless of rarity.

## Tech Stack

- **Flutter** (Dart)
- **Supabase** -- auth, Postgres database, Row Level Security
- **Pokemon art** -- loaded at runtime from [HybridShivam/Pokemon](https://github.com/HybridShivam/Pokemon/tree/master/assets/images)

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- A Supabase project with the required tables and RLS policies (see `lib/services/supabase_service.dart` for the schema)

### Run

```bash
flutter pub get
flutter run
```

### Build for iOS

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Under **Signing & Capabilities**, select your team and set a unique bundle ID.
3. Connect your iPhone and run `flutter run` from the terminal.

### Analyze & Test

```bash
dart analyze
flutter test
```
