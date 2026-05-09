import Foundation
import GRDB
import SwiftUI


struct PokemonRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemon" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "order" INTEGER, "height" INTEGER, "weight" INTEGER, "base_experience" INTEGER, "is_default" INTEGER NOT NULL, "pokemon_species_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_pokemon"
    
    let id: Int
    let name: String
    let order: Int?
    let height: Int
    let weight: Int
    let base_experience: Int?
    let is_default: Bool
    let pokemon_species_id: Int
}

struct PokemonSpeciesRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemonspecies" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "order" INTEGER, "gender_rate" INTEGER, "capture_rate" INTEGER, "base_happiness" INTEGER, "is_baby" INTEGER NOT NULL, "hatch_counter" INTEGER, "has_gender_differences" INTEGER NOT NULL, "forms_switchable" INTEGER NOT NULL, "evolution_chain_id" INTEGER, "evolves_from_species_id" INTEGER, "generation_id" INTEGER, "growth_rate_id" INTEGER, "pokemon_color_id" INTEGER, "pokemon_habitat_id" INTEGER, "pokemon_shape_id" INTEGER, "is_legendary" INTEGER NOT NULL, "is_mythical" INTEGER NOT NULL);
    
    static let databaseTableName = "pokemon_v2_pokemonspecies"
    
    let id: Int
    let name: String
    let order: Int?
    let gender_rate: Int?
    let capture_rate: Int?
    let base_happiness: Int?
    let is_baby: Bool
    let hatch_counter: Int?
    let has_gender_differences: Bool
    let forms_switchable: Bool
    let evolution_chain_id: Int?
    let evolves_from_species_id: Int?
    let generation_id: Int?
    let growth_rate_id: Int?
    let pokemon_color_id: Int?
    let pokemon_habitat_id: Int?
    let pokemon_shape_id: Int?
    let is_legendary: Bool
    let is_mythical: Bool
}

struct PokemonFormRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemonform" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "order" INTEGER, "form_name" TEXT NOT NULL, "is_default" INTEGER NOT NULL, "is_battle_only" INTEGER NOT NULL, "is_mega" INTEGER NOT NULL, "version_group_id" INTEGER, "pokemon_id" INTEGER, "form_order" INTEGER);
    
    static let databaseTableName = "pokemon_v2_pokemonform"
    
    let id: Int
    let name: String
    let order: Int?
    let form_name: String
    let is_default: Bool
    let is_battle_only: Bool
    let is_mega: Bool
    let version_group_id: Int?
    let pokemon_id: Int
    let form_order: Int?
}

struct PokemonFormNameRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemonformname" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "pokemon_name" TEXT NOT NULL, "language_id" INTEGER, "pokemon_form_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_pokemonformname"
    
    let id: Int
    let name: String
    let pokemon_name: String
    let language_id: Int
    let pokemon_form_id: Int
}

struct PokemonSpeciesNameRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemonspeciesname" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "genus" TEXT NOT NULL, "language_id" INTEGER, "pokemon_species_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_pokemonspeciesname"
    
    let id: Int
    let name: String
    let genus: String
    let language_id: Int
    let pokemon_species_id: Int
}

struct PokemonTypeRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemontype" ("id" INTEGER NOT NULL, "slot" INTEGER NOT NULL, "pokemon_id" INTEGER, "type_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_pokemontype"
    
    let id: Int
    let slot: Int
    let pokemon_id: Int
    let type: PokemonType

    enum CodingKeys: String, CodingKey {
        case id
        case slot
        case pokemon_id
        case type = "type_id"
    }
}

struct PokemonAbilityRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemonability" ("id" INTEGER NOT NULL, "is_hidden" INTEGER NOT NULL, "slot" INTEGER NOT NULL, "ability_id" INTEGER, "pokemon_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_pokemonability"
    
    let id: Int
    let is_hidden: Bool
    let slot: Int
    let ability_id: Int
    let pokemon_id: Int
}

struct AbilityNameRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_abilityname" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "ability_id" INTEGER, "language_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_abilityname"
    
    let id: Int
    let name: String
    let ability_id: Int
    let language_id: Int
}

struct PokemonStatRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemonstat" ("id" INTEGER NOT NULL, "base_stat" INTEGER NOT NULL, "effort" INTEGER NOT NULL, "pokemon_id" INTEGER, "stat_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_pokemonstat"
    
    let id: Int
    let base_stat: Int
    let effort: Int
    let pokemon_id: Int
    let stat_id: Int
}

struct MoveRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_move" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "power" INTEGER, "pp" INTEGER, "accuracy" INTEGER, "priority" INTEGER, "move_effect_chance" INTEGER, "generation_id" INTEGER, "move_damage_class_id" INTEGER, "move_effect_id" INTEGER, "move_target_id" INTEGER, "type_id" INTEGER, "contest_effect_id" INTEGER, "contest_type_id" INTEGER, "super_contest_effect_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_move"
    
    let id: Int
    let name: String
    let power: Int?
    let pp: Int?
    let accuracy: Int?
    let priority: Int
    let move_effect_chance: Int?
    let generation_id: Int
    let move_damage_class_id: Int
    let move_effect_id: Int?
    let move_target_id: Int
    let type: PokemonType
    let contest_effect_id: Int?
    let contest_type_id: Int?
    let super_contest_effect_id: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case power
        case pp
        case accuracy
        case priority
        case move_effect_chance
        case generation_id
        case move_damage_class_id
        case move_effect_id
        case move_target_id
        case type = "type_id"
        case contest_effect_id
        case contest_type_id
        case super_contest_effect_id
    }
}

struct PokemonMoveRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_pokemonmove" ("id" INTEGER NOT NULL, "order" INTEGER, "level" INTEGER NOT NULL, "move_id" INTEGER, "pokemon_id" INTEGER, "version_group_id" INTEGER, "move_learn_method_id" INTEGER, "mastery" INTEGER);
    
    static let databaseTableName = "pokemon_v2_pokemonmove"
    
    let id: Int
    let order: Int?
    let level: Int
    let move_id: Int
    let pokemon_id: Int
    let version_group_id: Int
    let move_learn_method_id: Int
    let mastery: Int?
}

struct MoveNameRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_movename" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "language_id" INTEGER, "move_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_movename"
    
    let id: Int
    let name: String
    let language_id: Int
    let move_id: Int
}

struct MoveFlavorTextRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_moveflavortext" ("id" INTEGER NOT NULL, "flavor_text" TEXT NOT NULL, "language_id" INTEGER, "move_id" INTEGER, "version_group_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_moveflavortext"
    
    let id: Int
    let flavor_text: String
    let language_id: Int
    let move_id: Int
    let version_group_id: Int
}

struct VersionGroupRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_versiongroup" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "order" INTEGER, "generation_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_versiongroup"
    
    static let databaseSelection: [any SQLSelectable] = [AllColumns(), Column.rowID]
    
    let id: Int
    let name: String
    let order: Int?
    let generation_id: Int
}

struct VersionRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_version" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "version_group_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_version"
    
    static let databaseSelection: [any SQLSelectable] = [AllColumns(), Column.rowID]
    
    let id: Int
    let name: String
    let version_group_id: Int
}

struct VersionNameRecord: Decodable, Identifiable, FetchableRecord, TableRecord {
    // CREATE TABLE IF NOT EXISTS "pokemon_v2_versionname" ("id" INTEGER NOT NULL, "name" TEXT NOT NULL, "language_id" INTEGER, "version_id" INTEGER);
    
    static let databaseTableName = "pokemon_v2_versionname"
    
    let id: Int
    let name: String
    let language_id: Int
    let version_id: Int
}


// MARK: - Extensions (helper functions)
extension PokemonRecord {
    var spriteArtworkUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(self.id).png")
    }
    var spritePixelatedUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(self.id).png")
    }
    
    var formattedHeight: String { String(format: "%.1f m", Double(self.height) / 10) }
    var formattedWeight: String { String(format: "%.1f kg", Double(self.weight) / 10) }
}

extension PokemonSpeciesRecord {
    var formattedID: String {
        String(format: "#%04d", self.id)
    }
    
    var spriteArtworkUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(self.id).png")
    }
    var spritePixelatedUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(self.id).png")
    }
}

// MARK: - SQL Columns
extension PokemonRecord {
    enum Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let order = Column("order")
        static let pokemonSpeciesID = Column("pokemon_species_id")
    }
}

extension PokemonSpeciesRecord {
    enum Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let order = Column("order")
    }
}

extension PokemonFormRecord {
    enum Columns {
        static let id = Column("id")
        static let pokemonID = Column("pokemon_id")
        static let name = Column("name")
        static let order = Column("order")
    }
}

extension PokemonSpeciesNameRecord {
    enum Columns {
        static let speciesID = Column("pokemon_species_id")
        static let languageID = Column("language_id")
    }
}

extension PokemonFormNameRecord {
    enum Columns {
        static let formID = Column("pokemon_form_id")
        static let languageID = Column("language_id")
    }
}

extension PokemonAbilityRecord {
    enum Columns {
        static let pokemonID = Column("pokemon_id")
        static let isHidden = Column("is_hidden")
        static let slot = Column("slot")
    }
}

extension PokemonTypeRecord {
    enum Columns {
        static let pokemonID = Column("pokemon_id")
        static let slot = Column("slot")
    }
}

extension AbilityNameRecord {
    enum Columns {
        static let abilityID = Column("ability_id")
        static let languageID = Column("language_id")
    }
}

extension PokemonStatRecord {
    enum Columns {
        static let pokemonID = Column("pokemon_id")
        static let statID = Column("stat_id")
    }
}

extension PokemonMoveRecord {
    enum Columns {
        static let order = Column("order")
        static let level = Column("level")
        static let moveID = Column("move_id")
        static let pokemonID = Column("pokemon_id")
        static let versionGroupID = Column("version_group_id")
        static let learnMethodID = Column("move_learn_method_id")
    }
}

extension MoveNameRecord {
    enum Columns {
        static let moveID = Column("move_id")
        static let languageID = Column("language_id")
    }
}

extension MoveFlavorTextRecord {
    enum Columns {
        static let moveID = Column("move_id")
        static let languageID = Column("language_id")
        static let versionGroupID = Column("version_group_id")
    }
}

extension VersionGroupRecord {
    enum Columns {
        static let id = Column("id")
        static let order = Column("order")
        static let generationID = Column("generation_id")
    }
}

// MARK: - Joins

// MARK: Pokemon Moves
extension PokemonMoveRecord {
    static let move = belongsTo(
        MoveRecord.self,
        key: "move",
        using: ForeignKey(["move_id"])
    )
}
extension MoveRecord {
    static let pokemonMoves = hasMany(
        PokemonMoveRecord.self,
        key: "pokemonMoves",
        using: ForeignKey(["move_id"])
    )
    static let flavorTexts = hasMany(
        MoveFlavorTextRecord.self,
        key: "flavorTexts",
        using: ForeignKey(["move_id"])
    )
}
extension MoveFlavorTextRecord {
    static let move = belongsTo(
        MoveRecord.self,
        key: "move",
        using: ForeignKey(["move_id"])
    )
}

struct PokemonMoveDetail: Decodable, FetchableRecord {
    let pokemonMove: PokemonMoveRecord
    let move: MoveRecord
    let flavorTexts: [MoveFlavorTextRecord]
}

// MARK: Game Versions
extension VersionRecord {
    static let versionGroup = belongsTo(
        VersionGroupRecord.self,
        key: "versionGroup",
        using: ForeignKey(["version_group_id"])
    )
    
    static let versionNames = hasMany(
        VersionNameRecord.self,
        key: "versionNames",
        using: ForeignKey(["version_id"])
    )
    
    static let englishName = hasOne(
        VersionNameRecord.self,
        key: "englishName",
        using: ForeignKey(["version_id"])
    )
        .filter(Column("language_id") == 9)
}
extension VersionNameRecord {
    static let version = belongsTo(
        VersionRecord.self,
        key: "version",
        using: ForeignKey(["version_id"])
    )
}
extension VersionGroupRecord {
    static let versions = hasMany(
        VersionRecord.self,
        key: "versions",
        using: ForeignKey(["version_group_id"])
    )
}

struct VersionDetail: Decodable, FetchableRecord {
    let version: VersionRecord
    let versionNames: [VersionNameRecord]
}
struct VersionGroupDetail: Decodable, FetchableRecord {
    let versionGroup: VersionGroupRecord
    let versions: [VersionDetail]
}

extension VersionGroupDetail {
    func combinedNames(forLanguage lang: PokemonLanguage) -> String {
        // example: "Red, Blue"
        self.versions.compactMap { version in
            version.versionNames.named(lang)?.name
        }.joined(separator: ", ")
    }
}


// MARK: - Language Helpers
enum PokemonLanguage: Int {
    case jaHrkt  = 1
    case jaRoma  = 2
    case ko      = 3
    case zhHant  = 4
    case fr      = 5
    case de      = 6
    case es      = 7
    case it      = 8
    case en      = 9
    case cs      = 10
    case ja      = 11
    case zhHans  = 12
    case ptBr    = 13
}

protocol LanguageScoped {
    var language_id: Int { get }
}

extension Array where Element: LanguageScoped {
    func named(_ language: PokemonLanguage) -> Element? {
        first { $0.language_id == language.rawValue }
    }

    var english:  Element? { named(.en) }
    var japanese: Element? { named(.ja) }
    var korean:   Element? { named(.ko) }
    var french:   Element? { named(.fr) }
    var german:   Element? { named(.de) }
    var spanish:  Element? { named(.es) }
    var italian:  Element? { named(.it) }
    var chinese:  Element? { named(.zhHans) }
}

extension PokemonSpeciesNameRecord: LanguageScoped {}
extension PokemonFormNameRecord: LanguageScoped {}
extension AbilityNameRecord: LanguageScoped {}
extension VersionNameRecord: LanguageScoped {}
extension MoveNameRecord: LanguageScoped {}
extension MoveFlavorTextRecord: LanguageScoped {}

// MARK: - Types

enum PokemonType: Int, Decodable, Identifiable {
    var id: Int { rawValue }
    var name: String {
        String(describing: self)
    }
    
    case normal = 1
    case fighting = 2
    case flying = 3
    case poison = 4
    case ground = 5
    case rock = 6
    case bug = 7
    case ghost = 8
    case steel = 9
    case fire = 10
    case water = 11
    case grass = 12
    case electric = 13
    case psychic = 14
    case ice = 15
    case dragon = 16
    case dark = 17
    case fairy = 18
    
    // Special types
    case stellar = 19
    case unknown = 10001
    case shadow = 10002
}

extension PokemonType {
    struct TypeColors {
        let bg: Color
        let accent: Color
        let darkAccent: Color

        var dim: Color  { bg.opacity(0.15) }
        var glow: Color { bg.opacity(0.5) }

        func labelAccent(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? accent : darkAccent
        }
    }

    var colors: TypeColors {
        switch self {
        case .fire:
            return TypeColors(bg: Color(hex: "#FF6B35"), accent: Color(hex: "#FF8C5A"), darkAccent: Color(hex: "#CC4A1A"))
        case .water:
            return TypeColors(bg: Color(hex: "#4A90D9"), accent: Color(hex: "#6AAEE8"), darkAccent: Color(hex: "#2B6FAD"))
        case .grass:
            return TypeColors(bg: Color(hex: "#5DB85D"), accent: Color(hex: "#7ACC7A"), darkAccent: Color(hex: "#3A8C3A"))
        case .electric:
            return TypeColors(bg: Color(hex: "#F5C518"), accent: Color(hex: "#FFD740"), darkAccent: Color(hex: "#A07800"))
        case .psychic:
            return TypeColors(bg: Color(hex: "#E0558E"), accent: Color(hex: "#EC7AAD"), darkAccent: Color(hex: "#B03070"))
        case .ice:
            return TypeColors(bg: Color(hex: "#74C7D4"), accent: Color(hex: "#96D8E2"), darkAccent: Color(hex: "#3A8C99"))
        case .dragon:
            return TypeColors(bg: Color(hex: "#7B6FE0"), accent: Color(hex: "#9E94E8"), darkAccent: Color(hex: "#4B3BA0"))
        case .dark:
            return TypeColors(bg: Color(hex: "#7A6A5A"), accent: Color(hex: "#9A8A7A"), darkAccent: Color(hex: "#4A3A2A"))
        case .fighting:
            return TypeColors(bg: Color(hex: "#C84B2F"), accent: Color(hex: "#E06040"), darkAccent: Color(hex: "#9C2E16"))
        case .poison:
            return TypeColors(bg: Color(hex: "#9B59B6"), accent: Color(hex: "#B87FCC"), darkAccent: Color(hex: "#7D3F99"))
        case .ground:
            return TypeColors(bg: Color(hex: "#C8A45A"), accent: Color(hex: "#D8BC7A"), darkAccent: Color(hex: "#8C6820"))
        case .rock:
            return TypeColors(bg: Color(hex: "#8B7355"), accent: Color(hex: "#A89070"), darkAccent: Color(hex: "#5A4A30"))
        case .bug:
            return TypeColors(bg: Color(hex: "#8BC34A"), accent: Color(hex: "#A8D870"), darkAccent: Color(hex: "#4A7A10"))
        case .ghost:
            return TypeColors(bg: Color(hex: "#7B6AAA"), accent: Color(hex: "#9E8FCC"), darkAccent: Color(hex: "#4A3A7A"))
        case .steel:
            return TypeColors(bg: Color(hex: "#8C9DB5"), accent: Color(hex: "#A8BACE"), darkAccent: Color(hex: "#4A6080"))
        case .fairy:
            return TypeColors(bg: Color(hex: "#F0A0C0"), accent: Color(hex: "#F5C0D5"), darkAccent: Color(hex: "#B03070"))
        case .flying:
            return TypeColors(bg: Color(hex: "#7BB8E8"), accent: Color(hex: "#9CCCF0"), darkAccent: Color(hex: "#3A70A0"))
        case .normal, .stellar, .unknown, .shadow:
            return TypeColors(bg: Color(hex: "#A0A0A0"), accent: Color(hex: "#BEBEBE"), darkAccent: Color(hex: "#606060"))
        }
    }
}
