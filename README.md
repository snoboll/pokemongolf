# Bogeybeasts

A Flutter app that combines golf scoring with Bogeybeast catching. Every hole on the course triggers a random Bogeybeast encounter, and your golf score determines the catch rate.

## Game Modes

### Catch Round

The core mode -- play golf, catch Bogeybeasts.

- Pick a course (or play without one) and choose 9, 18, or a full loop.
- On each hole, enter the par, your strokes, and any terrain flags (one-putt, bunker, water, rough).
- A wild Bogeybeast appears, weighted by rarity tier and your terrain flags.
- Your score sets the catch chance -- eagle or better is always 100%; bogey or worse drops sharply with rarity.
- A **legendary streak** builds with consecutive par-or-better holes (+3 par, +6 birdie, +12 eagle) and resets on a bogey or worse, raising your legendary encounter chance.
- Every catch rolls a 1-in-256 shiny.
- Finish the round (or end early) to save the scorecard; rounds feed your handicap.

### Battle

Golf-powered combat against another player.

- Build a team of 3 Bogeybeasts from your Bogeydex (you must have caught at least 3).
- Challenge another golfer over 9 or 18 holes on a chosen course.
- Each hole, both players submit their strokes. The lower score attacks; the opponent's active Bogeybeast takes damage.
- Damage scales with the attacker's offense, the defender's defense, the stroke gap, and type effectiveness (a Pokemon-style advantage chart).
- A Bogeybeast faints at 0 HP and the next team member steps in.
- First player to knock out the opponent's whole team wins. A win grants an **evolution** for one of your team members.

### Leader Challenge

A Battle against the golfer (or NPC) who holds a course.

- Every course has a Course Leader with a fixed 3-Bogeybeast team.
- Challenge them with the same team and battle rules as a standard Battle.
- Win and you **claim the course** -- you become its new leader and your battle team defends it.
- Lose and the leader keeps their throne.
- If the battle ends before all holes are played, you can continue the remaining holes as a normal Catch Round on the same scorecard.

## Features

- **217 preset courses** from across Sweden (Orestad, Falsterbo, Barseback, PGA National, and more), plus the ability to add custom courses.
- **Home course** -- set a favorite course for quick access.
- **5 rarity tiers** -- Common, Uncommon, Rare, Epic, and Legendary, each with distinct encounter weights and catch rates.
- **Shiny variants** -- a 1-in-256 chance any caught Bogeybeast is a shiny, with recolored art and a sparkle badge. Shiny status carries through evolution.
- **Terrain modifiers** -- toggle one-putt, bunker, water, and rough to boost encounter rates for matching Bogeybeast types.
- **Legendary streak** -- consecutive par-or-better holes increase your legendary encounter chance.
- **Scorecard history** -- review hole-by-hole results for every completed round.
- **Bogeydex** -- browse all 151 first-gen Bogeybeasts with All / Seen / Caught filters, rarity badges, and per-beast flavor text.
- **Golfers leaderboard** -- see other players' Bogeydex progress, shinies, bags, and home courses.
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
- **Bogeybeast art** -- bundled local assets in `assets/bogeybeasts_imgs/`

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
