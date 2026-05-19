import SwiftUI

@Observable
@MainActor
class BattleSession {
    enum Phase {
        case idle
        case waiting
        case inBattle(you: BattleSideState, opponent: BattleSideState)
        case ended(winner: BattleEndWinner, reason: BattleEndReason)
    }
    
    private(set) var phase: Phase = .idle
    private(set) var movePending = false
    private(set) var lastOutcomes: [MoveOutcome] = []
    private var task: URLSessionWebSocketTask?
    
    func connect(token: String, teamId: Int) {
        var request = URLRequest(url: URL(string: Constants.wsURL)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        task = URLSession.shared.webSocketTask(with: request)
        task?.resume()
        startReceiving()
        send(.joinQueue(teamId: teamId))
    }
    
    private func startReceiving() {
        Task {
            do {
                while let task {
                    let message = try await task.receive()
                    handle(message)
                }
            } catch {
                if case .ended = phase { return }
                phase = .idle
            }
        }
    }
    
    private func handle(_ message: URLSessionWebSocketTask.Message) {
        guard case .string(let json) = message,
              let data = json.data(using: .utf8),
              let serverMessage = try? JSONDecoder().decode(ServerMessage.self, from: data)
        else { return }

        switch serverMessage {
        case .waiting:
            phase = .waiting
        case .battleStart(let you, let opponent):
            phase = .inBattle(you: you, opponent: opponent)
            lastOutcomes = []
        case .turnResult(let outcomes, let you, let opponent):
            phase = .inBattle(you: you, opponent: opponent)
            lastOutcomes = outcomes
            movePending = false
        case .battleEnd(let winner, let reason):
            phase = .ended(winner: winner, reason: reason)
            task?.cancel(with: .normalClosure, reason: nil)
            task = nil
        case .error:
            break
        }
    }
    
    private func send(_ message: ClientMessage) {
        Task {
            guard let data = try? JSONEncoder().encode(message),
                  let json = String(data: data, encoding: .utf8) else { return }
            try? await task?.send(.string(json))
        }
    }

    func selectMove(_ moveId: Int) {
        send(.selectMove(moveId: moveId))
        movePending = true
    }
    func forfeit() {
        send(.forfeit)
    }

    func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
        phase = .idle
    }
}
