import SwiftUI

struct TypeBadge: View {
    let type: PokemonType
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text(type.name)
            .textCase(.uppercase)
            .font(.system(size: 14, weight: .heavy))
            .tracking(1.2)
            .foregroundStyle(colorScheme == .dark ? type.colors.accent : .white)
            .padding(.vertical, 4)
            .padding(.horizontal, 14)
            .background(colorScheme == .dark ? type.colors.dim : type.colors.bg, in: Capsule())
            .overlay(
                Capsule().stroke(type.colors.bg.opacity(colorScheme == .dark ? 0.25 : 0), lineWidth: 1)
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        TypeBadge(type: PokemonType(name: "fire", id: 10))
        TypeBadge(type: PokemonType(name: "water", id: 11))
    }
    .padding()
    .background(.black)
    .environment(\.colorScheme, .dark)
    
    VStack(spacing: 16) {
        TypeBadge(type: PokemonType(name: "fire", id: 10))
        TypeBadge(type: PokemonType(name: "water", id: 11))
    }
    .padding()
    .background(.white)
    .environment(\.colorScheme, .light)
}
