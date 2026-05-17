import SwiftUI

struct LoginSheet: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    
    @State var isRegistering: Bool

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var fieldErrors: [String: String] = [:]

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                        if let error = fieldErrors["username"] {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.top, 2)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        SecureField("Password", text: $password)
                        if let error = fieldErrors["password"] {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.vertical)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") { dismiss() }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            Task { await submit() }
                        } label: {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text(isRegistering ? "Register" : "Log In")
                                    .foregroundStyle(.white)
                            }
                        }
                        .disabled(isLoading)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        if let error = errorMessage {
                            Text(error)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(isRegistering ? "Already have an account? Log in" : "No account? Register") {
                            withAnimation {
                                isRegistering.toggle()
                                errorMessage = nil
                            }
                        }
                        .font(.footnote)
                        .padding()
                    }
                }
            }
            .navigationTitle(isRegistering ? "Register" : "Log In")
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        fieldErrors = [:]
        do {
            if isRegistering {
                try await authManager.register(username: username, password: password)
            } else {
                try await authManager.login(username: username, password: password)
            }
            dismiss()
        } catch BackendError.validation(let errors) {
            for error in errors {
                fieldErrors[error.field] = error.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    LoginSheet(isRegistering: false)
        .environment(AuthManager.preview())
}
