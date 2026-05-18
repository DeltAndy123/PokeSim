# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project — open `PokeSim.xcodeproj` in Xcode and run from there. There is no CLI build script. Swift Package dependencies (GRDB, SwiftUI-Flow) are resolved automatically by Xcode on first open.

The backend is expected at `http://localhost:3000` (hardcoded in `AuthManager.swift`). Auth features require the backend running; the rest of the app works offline.

## Architecture

**Two separate data stores run in parallel:**

1. **`PokemonDatabase`** (read-only singleton) — wraps a bundled `pokemon.sqlite` using GRDB. All tables use the PokeAPI schema prefix `pokemon_v2_`. This is where all Pokémon species, moves, types, abilities, stats, and version data live. Access it via `PokemonDatabase.shared`.

2. **SwiftData** (`PokemonTeam` + `TeamMember`) — persists user-created teams on-device. `TeamMember` stores only a `pokemonID` and `moveIDs` (integers); actual Pokémon data is always fetched from `PokemonDatabase` at runtime. The ModelContainer is set up in `PokeSimApp`.

**Auth flow:** `AuthManager` (@Observable, MainActor) holds `currentUser: UserProfile?`. It manages a JWT stored in the Keychain, communicates via `BackendClient`, and is injected as an environment object at the root. All views check `authManager.isLoggedIn` for auth-gated UI.

**Navigation:** `ContentView` is a `TabView` with four tabs — Home, Teams, Battle (stub), Search. Each tab is its own `NavigationStack`.

**Type theming:** `PokemonType` is an enum that maps each type to a `TypeColors` struct (bg, accent, darkAccent). Views derive accent colors from the dominant type of a team's Pokémon. Use `dominantType?.colors.labelAccent(for: colorScheme)` to get the right shade for light/dark mode.

**Sprites:** Loaded remotely from the PokeAPI sprites GitHub repo via `spriteArtworkUrl` and `spritePixelatedUrl` computed properties on `PokemonRecord`/`PokemonSpeciesRecord`.

**Multi-language:** `PokemonLanguage` enum (rawValue = language_id in DB). The `LanguageScoped` protocol + `Array.named(_:)` extension lets you filter name records by language. English is language ID 9.

## Key Patterns

- GRDB model types conform to `FetchableRecord & TableRecord`. Column names use `snake_case` matching the DB schema; Swift property names also use `snake_case` for direct decoding except where `CodingKeys` remaps (e.g., `type_id` → `.type`).
- GRDB associations (belongsTo/hasMany) are declared as static lets on the record types in `PokemonModel.swift`.
- SwiftData models (`PokemonTeam`, `TeamMember`) each have a `static var preview` / `static var previewTeam` for use in `#Preview` macros.
- The primary team is tracked by UUID string in `@AppStorage("primaryTeamID")`.

## Dependencies

- **GRDB.swift 7.10.0** — SQLite ORM for reading `pokemon.sqlite`
- **SwiftUI-Flow 3.1.1** — flow/wrap layout for SwiftUI (used in move/type displays)
