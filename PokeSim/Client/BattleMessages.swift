import Foundation

// MARK: - Client -> Server

enum ClientMessage: Encodable {
    case joinQueue(teamId: Int)
    case selectMove(moveId: Int)
    case forfeit

    private enum CodingKeys: String, CodingKey {
        case type, teamId, moveId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .joinQueue(let teamId):
            try container.encode("join_queue", forKey: .type)
            try container.encode(teamId, forKey: .teamId)
        case .selectMove(let moveId):
            try container.encode("select_move", forKey: .type)
            try container.encode(moveId, forKey: .moveId)
        case .forfeit:
            try container.encode("forfeit", forKey: .type)
        }
    }
}

// MARK: - Server -> Client

struct BattlePokemonState: Decodable {
    let pokemonId: Int
    let hp: Int
    let moves: [Int]
}

struct BattleSideState: Decodable {
    let userId: Int
    let pokemon: [BattlePokemonState]
    let activeSlot: Int
}

struct MoveOutcome: Decodable {
    let userId: Int
    let moveId: Int
    let targetUserId: Int
    let damageDealt: Int
    let effectiveness: Int
    let fainted: Bool
}

enum BattleEndWinner: String, Decodable {
    case you, opponent
}

enum BattleEndReason: String, Decodable {
    case knockout, forfeit, disconnect

    func description(winner: BattleEndWinner) -> String {
        switch (self, winner) {
        case (.knockout, .you):       "You knocked out your opponent"
        case (.knockout, .opponent):  "You were knocked out"
        case (.forfeit, .you):        "Opponent forfeited"
        case (.forfeit, .opponent):   "You forfeited"
        case (.disconnect, .you):     "You disconnected"
        case (.disconnect, .opponent):"Opponent disconnected"
        }
    }
}

enum ServerMessage: Decodable {
    case waiting
    case battleStart(you: BattleSideState, opponent: BattleSideState)
    case turnResult(outcomes: [MoveOutcome], you: BattleSideState, opponent: BattleSideState)
    case battleEnd(winner: BattleEndWinner, reason: BattleEndReason)
    case error(message: String)

    private enum CodingKeys: String, CodingKey {
        case type, you, opponent, outcomes, winner, reason, message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "waiting":
            self = .waiting
        case "battle_start":
            self = .battleStart(
                you: try container.decode(BattleSideState.self, forKey: .you),
                opponent: try container.decode(BattleSideState.self, forKey: .opponent)
            )
        case "turn_result":
            self = .turnResult(
                outcomes: try container.decode([MoveOutcome].self, forKey: .outcomes),
                you: try container.decode(BattleSideState.self, forKey: .you),
                opponent: try container.decode(BattleSideState.self, forKey: .opponent)
            )
        case "battle_end":
            self = .battleEnd(
                winner: try container.decode(BattleEndWinner.self, forKey: .winner),
                reason: try container.decode(BattleEndReason.self, forKey: .reason)
            )
        case "error":
            self = .error(message: try container.decode(String.self, forKey: .message))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown message type: \(type)"
            )
        }
    }
}
