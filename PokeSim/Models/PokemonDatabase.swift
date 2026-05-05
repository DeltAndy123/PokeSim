import Foundation
import GRDB

final class PokemonDatabase {
    static let shared = PokemonDatabase()

    private let dbQueue: DatabaseQueue

    private init() {
        guard let dbURL = Bundle.main.url(forResource: "pokemon", withExtension: "sqlite") else {
            fatalError("Could not find pokemon.sqlite in app bundle")
        }

        do {
            var config = Configuration()
            config.readonly = true

            self.dbQueue = try DatabaseQueue(path: dbURL.path, configuration: config)
        } catch {
            fatalError("Could not open pokemon.sqlite: \(error)")
        }
    }
}



// MARK: - Species
extension PokemonDatabase {
    func allSpecies() -> [PokemonSpeciesRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonSpeciesRecord
                    .order(PokemonSpeciesRecord.Columns.order)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch species: \(error)")
            return []
        }
    }
    
    func species(byID id: Int) -> PokemonSpeciesRecord? {
        do {
            return try dbQueue.read { db in
                try PokemonSpeciesRecord
                    .filter(PokemonSpeciesRecord.Columns.id == id)
                    .fetchOne(db)
            }
        } catch {
            print("Failed to fetch species by ID: \(error)")
            return nil
        }
    }
}

// MARK: - Pokemon
extension PokemonDatabase {
    func allPokemon() -> [PokemonRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonRecord
                    .order(PokemonRecord.Columns.order)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch pokemon: \(error)")
            return []
        }
    }

    func pokemon(byID id: Int) -> PokemonRecord? {
        do {
            return try dbQueue.read { db in
                try PokemonRecord
                    .filter(PokemonRecord.Columns.id == id)
                    .fetchOne(db)
            }
        } catch {
            print("Failed to fetch pokemon by ID \(id): \(error)")
            return nil
        }
    }

    func pokemon(forSpeciesID speciesID: Int) -> [PokemonRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonRecord
                    .filter(PokemonRecord.Columns.pokemonSpeciesID == speciesID)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch pokemon for species \(speciesID): \(error)")
            return []
        }
    }
}

// MARK: - Extra Pokemon Info
extension PokemonDatabase {
    func types(forPokemonID pokemonID: Int) -> [PokemonTypeRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonTypeRecord
                    .filter(PokemonTypeRecord.Columns.pokemonID == pokemonID)
                    .order(PokemonTypeRecord.Columns.slot)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch types for pokemon \(pokemonID): \(error)")
            return []
        }
    }

    func abilities(forPokemonID pokemonID: Int) -> [PokemonAbilityRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonAbilityRecord
                    .filter(PokemonAbilityRecord.Columns.pokemonID == pokemonID)
                    .order(PokemonAbilityRecord.Columns.slot)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch abilities for pokemon \(pokemonID): \(error)")
            return []
        }
    }
    
    func normalAbilities(forPokemonID pokemonID: Int) -> [PokemonAbilityRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonAbilityRecord
                    .filter(
                        PokemonAbilityRecord.Columns.pokemonID == pokemonID &&
                        PokemonAbilityRecord.Columns.isHidden == false
                    )
                    .order(PokemonAbilityRecord.Columns.slot)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch normal abilities for pokemon \(pokemonID): \(error)")
            return []
        }
    }
    func hiddenAbilities(forPokemonID pokemonID: Int) -> [PokemonAbilityRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonAbilityRecord
                    .filter(
                        PokemonAbilityRecord.Columns.pokemonID == pokemonID &&
                        PokemonAbilityRecord.Columns.isHidden == true
                    )
                    .order(PokemonAbilityRecord.Columns.slot)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch hidden abilities for pokemon \(pokemonID): \(error)")
            return []
        }
    }

    struct PokemonStats {
        let hp: Int
        let attack: Int
        let defense: Int
        let spAtk: Int
        let spDef: Int
        let speed: Int

        var total: Int {
            hp + attack + defense + spAtk + spDef + speed
        }
    }
    func stats(forPokemonID pokemonID: Int) -> PokemonStats {
        do {
            let statsList = try dbQueue.read { db in
                try PokemonStatRecord
                    .filter(PokemonStatRecord.Columns.pokemonID == pokemonID)
                    .fetchAll(db)
            }
            
            let statsByID = Dictionary(
                uniqueKeysWithValues: statsList.map { ($0.stat_id, $0.base_stat) }
            )

            return PokemonStats(
                hp: statsByID[1] ?? 0,
                attack: statsByID[2] ?? 0,
                defense: statsByID[3] ?? 0,
                spAtk: statsByID[4] ?? 0,
                spDef: statsByID[5] ?? 0,
                speed: statsByID[6] ?? 0
            )
        } catch {
            print("Failed to fetch stats for pokemon \(pokemonID): \(error)")
            return PokemonStats(hp: 0, attack: 0, defense: 0, spAtk: 0, spDef: 0, speed: 0)
        }
    }
    
    func forms(forPokemonID pokemonID: Int) -> [PokemonFormRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonFormRecord
                    .filter(PokemonFormRecord.Columns.pokemonID == pokemonID)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch forms for pokemon \(pokemonID): \(error)")
            return []
        }
    }
    
    func moves(forPokemonID pokemonID: Int) -> [PokemonMoveRecord] {
        do {
            return try dbQueue.read { db in
                try PokemonMoveRecord
                    .filter(PokemonMoveRecord.Columns.pokemonID == pokemonID)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch forms for pokemon \(pokemonID): \(error)")
            return []
        }
    }
}

// MARK: - Search
extension PokemonDatabase {
    func searchSpecies(for query: String) -> [PokemonSpeciesRecord] {
        do {
            return try dbQueue.read { db in
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return try PokemonSpeciesRecord
                        .order(PokemonSpeciesRecord.Columns.order)
                        .fetchAll(db)
                }
                
                return try PokemonSpeciesRecord.fetchAll(
                    db,
                    sql: """
                    SELECT DISTINCT s.*
                    FROM pokemon_v2_pokemonspecies s
                    LEFT JOIN pokemon_v2_pokemonspeciesname sn
                        ON sn.pokemon_species_id = s.id
                    WHERE s.name LIKE ?
                       OR sn.name LIKE ?
                    ORDER BY s."order"
                    """,
                    arguments: ["%\(query)%", "%\(query)%"]
                )
            }
        } catch {
            print("Failed to search species: \(error)")
            return []
        }
    }
}

// MARK: - Name
extension PokemonDatabase {
    func englishSpeciesName(forSpeciesID speciesID: Int) -> PokemonSpeciesNameRecord? {
        do {
            return try dbQueue.read { db in
                try PokemonSpeciesNameRecord
                    .filter(
                        PokemonSpeciesNameRecord.Columns.speciesID == speciesID &&
                        PokemonSpeciesNameRecord.Columns.languageID == 9
                    )
                    .fetchOne(db)
            }
        } catch {
            print("Failed to fetch English species name: \(error)")
            return nil
        }
    }
    
    func englishFormName(forFormID formID: Int) -> PokemonFormNameRecord? {
        do {
            return try dbQueue.read { db in
                try PokemonFormNameRecord
                    .filter(
                        PokemonFormNameRecord.Columns.formID == formID &&
                        PokemonFormNameRecord.Columns.languageID == 9
                    )
                    .fetchOne(db)
            }
        } catch {
            print("Failed to fetch English form name: \(error)")
            return nil
        }
    }

    func englishAbilityName(forAbilityID abilityID: Int) -> AbilityNameRecord? {
        do {
            return try dbQueue.read { db in
                try AbilityNameRecord
                    .filter(
                        AbilityNameRecord.Columns.abilityID == abilityID &&
                        AbilityNameRecord.Columns.languageID == 9
                    )
                    .fetchOne(db)
            }
        } catch {
            print("Failed to fetch English ability name: \(error)")
            return nil
        }
    }
}

// MARK: - Joins
extension PokemonDatabase {
    func moveDetails(forPokemonID pokemonID: Int, versionGroupID: Int) -> [PokemonMoveDetail] {
        do {
            return try dbQueue.read { db in
                try PokemonMoveRecord
                    .filter(
                        PokemonMoveRecord.Columns.pokemonID == pokemonID &&
                        PokemonMoveRecord.Columns.versionGroupID == versionGroupID
                    )
                    .including(required: PokemonMoveRecord.move)
                    .order(
                        PokemonMoveRecord.Columns.learnMethodID,
                        PokemonMoveRecord.Columns.level,
                        PokemonMoveRecord.Columns.order
                    )
                    .asRequest(of: PokemonMoveDetail.self)
                    .fetchAll(db)
            }
        } catch {
            print("Failed to fetch move details: \(error)")
            return []
        }
    }
}
