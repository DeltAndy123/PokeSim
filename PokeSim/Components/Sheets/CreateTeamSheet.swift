import SwiftUI
import SwiftData

struct CreateTeamSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query var teams: [PokemonTeam]
    @Environment(\.dismiss) private var dismiss
    
    @State private var createTeamName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Team Name", text: $createTeamName)
                    .textInputAutocapitalization(.words)
                    .focused($isTextFieldFocused)
            }
            .navigationTitle("Create New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        let newTeam = PokemonTeam(name: createTeamName.trimmingCharacters(in: .whitespaces), sortIndex: teams.count, pokemonIDs: [])
                        modelContext.insert(newTeam)
                        dismiss()
                    }
                    .disabled(createTeamName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
        
    }
}
