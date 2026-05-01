import Foundation
import SwiftUI

// TODO: Remove all old Codable models and rename these to replace them

enum PokemonType: Int, Codable, Identifiable {
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

struct CSVPokemon: Codable, Identifiable {
    // id,identifier,species_id,height,weight,base_experience,order,is_default
    // 1,bulbasaur,1,7,69,64,1,1
    
    let id: Int
    let identifier: String
    let species_id: Int
    let height: Int
    let weight: Int
    let base_experience: Int?
    let order: Int?
    let is_default: Bool
}

struct CSVPokemonSpecies: Codable, Identifiable {
    // id,identifier,generation_id,evolves_from_species_id,evolution_chain_id,color_id,shape_id,habitat_id,gender_rate,capture_rate,base_happiness,is_baby,hatch_counter,has_gender_differences,growth_rate_id,forms_switchable,is_legendary,is_mythical,order,conquest_order
    // 1,bulbasaur,1,,1,5,8,3,1,45,70,0,20,0,4,0,0,0,1,
    // 2,ivysaur,1,1,1,5,8,3,1,45,70,0,20,0,4,0,0,0,2,
    
    let id: Int
    let identifier: String
    let generation_id: Int
    let evolves_from_species_id: Int?
    let evolution_chain_id: Int
    let color_id: Int
    let shape_id: Int
    let habitat_id: Int?
    let gender_rate: Int
    let capture_rate: Int
    let base_happiness: Int
    let is_baby: Bool
    let hatch_counter: Int
    let has_gender_differences: Bool
    let growth_rate_id: Int
    let forms_switchable: Bool
    let is_legendary: Bool
    let is_mythical: Bool
    let order: Int
    let conquest_order: Int?
}

struct CSVPokemonForm: Codable, Identifiable {
    // id,identifier,form_identifier,pokemon_id,introduced_in_version_group_id,is_default,is_battle_only,is_mega,form_order,order
    // 1,bulbasaur,,1,28,1,0,0,1,1
    // 641,tornadus-incarnate,incarnate,641,11,1,0,0,1,847
    
    let id: Int
    let identifier: String
    let form_identifier: String
    let pokemon_id: Int
    let introduced_in_version_group_id: Int
    let is_default: Bool
    let is_battle_only: Bool
    let is_mega: Bool
    let form_order: Int
    let order: Int
}

struct CSVPokemonFormName: Codable {
    // pokemon_form_id,local_language_id,form_name,pokemon_name
    // 201,9,A,Unown A
    
    let pokemon_form_id: Int
    let local_language_id: Int
    let form_name: String
    let pokemon_name: String
}

struct CSVPokemonSpeciesName: Codable {
    // pokemon_species_id,local_language_id,name,genus
    // 1,9,Bulbasaur,Seed Pokémon
    // 1,2,Fushigidane,
    
    let pokemon_species_id: Int
    let local_language_id: Int
    let name: String
    let genus: String?
}

struct CSVPokemonType: Codable {
    // pokemon_id,type_id,slot
    // 1,12,1
    
    let pokemon_id: Int
    let type: PokemonType
    let slot: Int

    enum CodingKeys: String, CodingKey {
        case pokemon_id
        case type = "type_id"
        case slot
    }
}

struct CSVPokemonAbility: Codable {
    // pokemon_id,ability_id,is_hidden,slot
    // 1,65,0,1
    
    let pokemon_id: Int
    let ability_id: Int
    let is_hidden: Bool
    let slot: Int?
}

struct CSVAbilityNames: Codable {
    // ability_id,local_language_id,name
    // 1,9,Stench
    
    let ability_id: Int
    let local_language_id: Int
    let name: String
}

struct CSVPokemonStat: Codable {
    // pokemon_id,stat_id,base_stat,effort
    // 1,1,45,0
    
    let pokemon_id: Int
    let stat_id: Int
    let base_stat: Int
    let effort: Int
}


// MARK: - Extensions (helper functions)
extension CSVPokemon {
    var spriteArtworkUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(self.id).png")
    }
    var spritePixelatedUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(self.id).png")
    }
    
    var formattedHeight: String { String(format: "%.1f m", Double(self.height) / 10) }
    var formattedWeight: String { String(format: "%.1f kg", Double(self.weight) / 10) }
    
    func types(from types: [CSVPokemonType]) -> [CSVPokemonType] {
        types.filter {
            $0.pokemon_id == self.id
        }
    }
    func primaryType(from typesList: [CSVPokemonType]) -> PokemonType? {
        types(from: typesList).first { $0.slot == 1 }?.type
    }
    func secondaryType(from typesList: [CSVPokemonType]) -> PokemonType? {
        types(from: typesList).first { $0.slot == 2 }?.type
    }
    
    func abilities(from abilities: [CSVPokemonAbility]) -> [CSVPokemonAbility] {
        abilities.filter {
            $0.pokemon_id == self.id
        }
    }
    func regularAbilities(from abilities: [CSVPokemonAbility]) -> [CSVPokemonAbility] {
        self.abilities(from: abilities).filter { !$0.is_hidden }
    }
    func hiddenAbility(from abilities: [CSVPokemonAbility]) -> CSVPokemonAbility? {
        self.abilities(from: abilities).first { $0.is_hidden }
    }
    
    func species(from species: [CSVPokemonSpecies]) -> CSVPokemonSpecies? {
        species.first {
            $0.id == self.species_id
        }
    }
    
    func forms(from forms: [CSVPokemonForm]) -> [CSVPokemonForm] {
        forms.filter {
            $0.pokemon_id == self.id
        }
    }
    
    
    struct Stats {
        let hp: Int
        let attack: Int
        let defense: Int
        let spAtk: Int
        let spDef: Int
        let speed: Int

        var total: Int { hp + attack + defense + spAtk + spDef + speed }
    }
    func stats(from statsList: [CSVPokemonStat]) -> Stats {
        let statsByID = Dictionary(
            uniqueKeysWithValues: statsList
                .filter { $0.pokemon_id == self.id }
                .map { ($0.stat_id, $0.base_stat) }
        )

        return Stats(
            hp:      statsByID[1] ?? 0,
            attack:  statsByID[2] ?? 0,
            defense: statsByID[3] ?? 0,
            spAtk:   statsByID[4] ?? 0,
            spDef:   statsByID[5] ?? 0,
            speed:   statsByID[6] ?? 0
        )
    }
}

extension CSVPokemonSpecies {
    func variants(from pokemon: [CSVPokemon]) -> [CSVPokemon] {
        pokemon.filter { $0.species_id == self.id }
    }
    
    var formattedID: String {
        String(format: "#%04d", self.id)
    }
    
    var spriteArtworkUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(self.id).png")
    }
    var spritePixelatedUrl: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(self.id).png")
    }
    
    func speciesEnglishName(from names: [CSVPokemonSpeciesName]) -> String? {
        return names.first {
            // language id 9 is english
            $0.local_language_id == 9 && self.id == $0.pokemon_species_id
        }?.name
    }
    func speciesAllNames(from names: [CSVPokemonSpeciesName]) -> [String] {
        return names.compactMap {
            self.id == $0.pokemon_species_id ? $0.name : nil
        }
    }
    
    func speciesEnglishGenus(from names: [CSVPokemonSpeciesName]) -> String? {
        return names.first {
            // language id 9 is english
            $0.local_language_id == 9 && self.id == $0.pokemon_species_id
        }?.genus
    }
}

extension CSVPokemonAbility {
    func englishName(from names: [CSVAbilityNames]) -> String? {
        return names.first {
            // language id 9 is english
            $0.local_language_id == 9 && self.ability_id == $0.ability_id
        }?.name
    }
}

extension CSVPokemonForm {
    func variant(from pokemon: [CSVPokemon]) -> CSVPokemon? {
        pokemon.first { $0.id == self.pokemon_id }
    }
    
    func englishName(from names: [CSVPokemonFormName]) -> CSVPokemonFormName? {
        return names.first {
            // language id 9 is english
            $0.local_language_id == 9 && $0.pokemon_form_id == self.id
        }
    }
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
