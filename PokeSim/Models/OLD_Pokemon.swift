//import Foundation
//import SwiftUI
//import UniformTypeIdentifiers
//
///*
// https://graphql.pokeapi.co/v1beta2/console/
// 
// query samplePokeAPIquery {
//   pokemonspecies(order_by: [{id: asc}]) {
//     id
//     pokemonspeciesnames(where: {language_id: {_eq: 9}}) {
//       name
//       genus
//     }
//     pokemons {
//       name
//       id
//       height
//       weight
//       base_experience
//       pokemonsprites {
//         front: sprites(path: "front_default")
//         official_front: sprites(path: "other.official-artwork.front_default")
//       }
//       pokemontypes {
//         type {
//           name
//           id
//         }
//       }
//       pokemonabilities {
//         ability {
//           id
//           name
//           abilitynames(where: {language_id: {_eq: 9}}) {
//             name
//           }
//         }
//         is_hidden
//       }
//       pokemonstats {
//         stat {
//           name
//         }
//         base_stat
//       }
//       pokemonforms {
//         id
//         pokemonformnames(where: {language_id: {_eq: 9}}) {
//           name
//           pokemon_name
//         }
//       }
//     }
//   }
// }
// */
//
//struct PokemonRoot: Codable {
//    let data: PokemonData
//}
//
//struct PokemonData: Codable {
//    let pokemonspecies: [PokemonSpecies]
//    
//    func search(_ query: String) -> [PokemonSpecies] {
//        if (query.isEmpty) { return pokemonspecies }
//        
//        let lowercased = query.lowercased()
//        return pokemonspecies.filter { species in
//            species.pokemonspeciesnames.contains { $0.name.lowercased().contains(lowercased) } ||
//            species.pokemons.contains { $0.name.lowercased().contains(lowercased) }
//        }
//    }
//    
//    func getByType(_ typeName: String) -> [PokemonSpecies] {
//        let lowercased = typeName.lowercased()
//        return pokemonspecies.filter { species in
//            species.pokemons.contains { pokemon in
//                pokemon.pokemontypes.contains { $0.type.name.lowercased() == lowercased }
//            }
//        }
//    }
//    
//    func getByID(_ id: Int) -> PokemonSpecies? {
//        pokemonspecies.first { $0.id == id }
//    }
//}
//
//struct PokemonSpecies: Codable, Identifiable {
//    let id: Int
//    let pokemonspeciesnames: [SpeciesNameWrapper]
//    let pokemons: [Pokemon]
//    
//    var idFormatted: String {
//        String(format: "#%04d", id)
//    }
//    
//    var primaryName: String {
//        pokemonspeciesnames.first?.name ?? "Unknown"
//    }
//    var primaryGenus: String {
//        pokemonspeciesnames.first?.genus ?? "Unknown Pokémon"
//    }
//    
//    var defaultForm: Pokemon? { pokemons.first }
//}
//
//struct Pokemon: Codable, Identifiable {
//    let name: String
//    let id: Int
//    let height: Int
//    let weight: Int
//    let base_experience: Int?
//    let pokemontypes: [PokemonTypeWrapper]
//    let pokemonabilities: [PokemonAbilityWrapper]
//    let pokemonstats: [PokemonStat]
//    let pokemonforms: [PokemonForm]
//    let pokemonsprites: [PokemonSprite]
//    
//    var sprites: PokemonSprite? { pokemonsprites.first }
//    
//    var heightMeters: Double { Double(height) / 10 }
//    var weightKilograms: Double { Double(weight) / 10 }
//
//    var heightFormatted: String { String(format: "%.1f m", heightMeters) }
//    var weightFormatted: String { String(format: "%.1f kg", weightKilograms) }
//    
//    var types: [PokemonType] { pokemontypes.map { $0.type } }
//    
//    var primaryType: PokemonType? { types.first }
//    var secondaryType: PokemonType? { types.count > 1 ? types[1] : nil }
//    
//    var commonAbilities: [PokemonAbility] {
//        return pokemonabilities.filter { !$0.is_hidden }.map { $0.ability }
//    }
//    var hiddenAbility: PokemonAbility? {
//        return pokemonabilities.first { $0.is_hidden }?.ability
//    }
//    
//    func hasType(_ typeName: String) -> Bool {
//        types.contains { $0.name.lowercased() == typeName.lowercased() }
//    }
//}
//
//struct PokemonForm: Codable, Identifiable {
//    let id: Int
//    let pokemonformnames: [PokemonFormNameWrapper]
//    
//    var formLabel: String { // Ex: Gigantamax Form
//        pokemonformnames.first?.name ?? ""
//    }
//    
//    var displayName: String { // Ex: Gigantamax Charizard
//        pokemonformnames.first?.pokemon_name ?? ""
//    }
//}
//
//struct PokemonSprite: Codable {
//    let front: String?
//    let official_front: String?
//}
//
//struct PokemonTypeWrapper: Codable {
//    let type: PokemonType
//}
//
//struct PokemonType: Codable, Identifiable {
//    let name: String
//    let id: Int
//}
//
//struct PokemonAbilityWrapper: Codable {
//    let ability: PokemonAbility
//    let is_hidden: Bool
//}
//
//struct PokemonAbility: Codable {
//    let id: Int
//    let name: String
//    let abilitynames: [NameWrapper]
//}
//
//struct PokemonStat: Codable {
//    let stat: NameWrapper
//    let base_stat: Int
//    
//    var name: String { stat.name }
//}
//
//
//struct NameWrapper: Codable {
//    let name: String
//}
//
//struct SpeciesNameWrapper: Codable {
//    let name: String
//    let genus: String
//}
//
//struct PokemonFormNameWrapper: Codable {
//    let name: String
//    let pokemon_name: String
//}
//
//
//extension Pokemon {
//    struct Stats {
//        let hp: Int
//        let attack: Int
//        let defense: Int
//        let spAtk: Int
//        let spDef: Int
//        let speed: Int
//        
//        var total: Int { hp + attack + defense + spAtk + spDef + speed }
//    }
//    
//    var stats: Stats {
//        func get(_ name: String) -> Int {
//            pokemonstats.first { $0.name == name }?.base_stat ?? 0
//        }
//        
//        return Stats(
//            hp:      get("hp"),
//            attack:  get("attack"),
//            defense: get("defense"),
//            spAtk:   get("special-attack"),
//            spDef:   get("special-defense"),
//            speed:   get("speed")
//        )
//    }
//}
//
//extension PokemonSpecies {
//    // Forms like mega, has different stats
//    var hasAlternateForms: Bool {
//        pokemons.count > 1
//    }
//    
//    // Only cosmetic variants
//    var hasCosmeticVariants: Bool {
//        pokemons.count == 1 &&
//        (pokemons.first?.pokemonforms.count ?? 0) > 1
//    }
//}
//
//extension Pokemon {
//    func formName(fallback: String) -> String {
//        if let displayName = pokemonforms.first?.displayName, !displayName.isEmpty {
//            return displayName
//        }
//        if let formLabel = pokemonforms.first?.formLabel, !formLabel.isEmpty {
//            return formLabel
//        }
//        return fallback
//    }
//}
//
//extension PokemonType {
//    struct TypeColors {
//        let bg: Color
//        let accent: Color
//        let darkAccent: Color
//        
//        var dim: Color  { bg.opacity(0.15) }
//        var glow: Color { bg.opacity(0.5)  }
//        
//        func labelAccent(for colorScheme: ColorScheme) -> Color {
//            colorScheme == .dark ? accent : darkAccent
//        }
//    }
//    
//    var colors: TypeColors {
//        switch name.lowercased() {
//        case "fire":     return TypeColors(bg: Color(hex: "#FF6B35"), accent: Color(hex: "#FF8C5A"), darkAccent: Color(hex: "#CC4A1A"))
//        case "water":    return TypeColors(bg: Color(hex: "#4A90D9"), accent: Color(hex: "#6AAEE8"), darkAccent: Color(hex: "#2B6FAD"))
//        case "grass":    return TypeColors(bg: Color(hex: "#5DB85D"), accent: Color(hex: "#7ACC7A"), darkAccent: Color(hex: "#3A8C3A"))
//        case "electric": return TypeColors(bg: Color(hex: "#F5C518"), accent: Color(hex: "#FFD740"), darkAccent: Color(hex: "#A07800"))
//        case "psychic":  return TypeColors(bg: Color(hex: "#E0558E"), accent: Color(hex: "#EC7AAD"), darkAccent: Color(hex: "#B03070"))
//        case "ice":      return TypeColors(bg: Color(hex: "#74C7D4"), accent: Color(hex: "#96D8E2"), darkAccent: Color(hex: "#3A8C99"))
//        case "dragon":   return TypeColors(bg: Color(hex: "#7B6FE0"), accent: Color(hex: "#9E94E8"), darkAccent: Color(hex: "#4B3BA0"))
//        case "dark":     return TypeColors(bg: Color(hex: "#7A6A5A"), accent: Color(hex: "#9A8A7A"), darkAccent: Color(hex: "#4A3A2A"))
//        case "fighting": return TypeColors(bg: Color(hex: "#C84B2F"), accent: Color(hex: "#E06040"), darkAccent: Color(hex: "#9C2E16"))
//        case "poison":   return TypeColors(bg: Color(hex: "#9B59B6"), accent: Color(hex: "#B87FCC"), darkAccent: Color(hex: "#7D3F99"))
//        case "ground":   return TypeColors(bg: Color(hex: "#C8A45A"), accent: Color(hex: "#D8BC7A"), darkAccent: Color(hex: "#8C6820"))
//        case "rock":     return TypeColors(bg: Color(hex: "#8B7355"), accent: Color(hex: "#A89070"), darkAccent: Color(hex: "#5A4A30"))
//        case "bug":      return TypeColors(bg: Color(hex: "#8BC34A"), accent: Color(hex: "#A8D870"), darkAccent: Color(hex: "#4A7A10"))
//        case "ghost":    return TypeColors(bg: Color(hex: "#7B6AAA"), accent: Color(hex: "#9E8FCC"), darkAccent: Color(hex: "#4A3A7A"))
//        case "steel":    return TypeColors(bg: Color(hex: "#8C9DB5"), accent: Color(hex: "#A8BACE"), darkAccent: Color(hex: "#4A6080"))
//        case "fairy":    return TypeColors(bg: Color(hex: "#F0A0C0"), accent: Color(hex: "#F5C0D5"), darkAccent: Color(hex: "#B03070"))
//        case "flying":   return TypeColors(bg: Color(hex: "#7BB8E8"), accent: Color(hex: "#9CCCF0"), darkAccent: Color(hex: "#3A70A0"))
//        case "normal":   return TypeColors(bg: Color(hex: "#A0A0A0"), accent: Color(hex: "#BEBEBE"), darkAccent: Color(hex: "#606060"))
//        default:         return TypeColors(bg: Color(hex: "#A0A0A0"), accent: Color(hex: "#BEBEBE"), darkAccent: Color(hex: "#606060"))
//        }
//    }
//}
//
//
//extension PokemonSpecies: Transferable {
//    static var transferRepresentation: some TransferRepresentation {
//        ProxyRepresentation { String($0.id) }
//    }
//}
