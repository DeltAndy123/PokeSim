import SwiftUI

struct PokemonMove: View {
    let moveDetail: PokemonMoveDetail
    
    private let db = PokemonDatabase.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(db.moveName(forMoveID: moveDetail.move.id, withLanguage: .en)?.name ?? moveDetail.move.name)
                    .bold()
                Spacer()
                TypeBadge(type: moveDetail.move.type)
            }
            
            if let englishFlavorText = moveDetail.flavorTexts.english?.flavor_text {
                let flavorText = englishFlavorText
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\n", with: " ")
                Text(flavorText)
                    .foregroundStyle(moveDetail.move.type.colors.accent)
            }
            
            let power: String = moveDetail.move.power.map(\.description) ?? "-"
            let accuracy: String = moveDetail.move.accuracy.map { "\($0)%" } ?? "-"
            let pp: String = moveDetail.move.pp.map(\.description) ?? "-"
            HStack(spacing: 10) {
                Image(systemName: "burst.fill")
                Text(power)
                Spacer()
                
                Image(systemName: "target")
                Text(accuracy)
                Spacer()
                
                Image(systemName: "bolt.fill")
                Text(pp)
            }
            .foregroundStyle(.secondary)
            .padding(.top, 2)
        }
        .padding()
        .background(moveDetail.move.type.colors.accent.opacity(0.25), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    if let move = PokemonDatabase.shared.moveDetails(forPokemonID: 1025).first {
        Text("\(move.move.id)")
        PokemonMove(moveDetail: move)
            .padding()
    }
}
