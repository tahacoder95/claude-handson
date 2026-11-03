import SwiftUI

/// Sign in or create an account. Success changes the session, which replaces this whole flow.
struct AuthView: View {
    @State private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    private enum Field {
        case username, password, displayName, phone
    }

    init(viewModel: AuthViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    header
                    fields
                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    submitButton
                    switchModeRow
                }
                .padding(Spacing.xl)
                .animation(.smooth, value: viewModel.mode)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                }
            }
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            BrandMark(size: 56)
                .padding(.bottom, Spacing.xs)
            Text(viewModel.title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.ink)
            Text(viewModel.subtitle)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    @ViewBuilder
    private var fields: some View {
        FormField(label: "Username") {
            TextField("e.g. omar", text: $viewModel.username)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .username)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
        }
        FormField(label: "Password") {
            SecureField(viewModel.mode == .register ? "At least 6 characters" : "Your password", text: $viewModel.password)
                .textContentType(viewModel.mode == .register ? .newPassword : .password)
                .focused($focusedField, equals: .password)
                .submitLabel(viewModel.mode == .register ? .next : .go)
                .onSubmit(passwordSubmitted)
        }
        if viewModel.mode == .register {
            FormField(label: "Your name") {
                TextField("Shown on your listings", text: $viewModel.displayName)
                    .textContentType(.name)
                    .focused($focusedField, equals: .displayName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .phone }
            }
            VStack(alignment: .leading, spacing: Spacing.xs) {
                FormField(label: "Phone number") {
                    TextField("+971 50 000 0000", text: $viewModel.phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phone)
                }
                Text("Buyers see this number when they tap Contact Seller.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private var submitButton: some View {
        Button {
            submit()
        } label: {
            if viewModel.isSubmitting {
                ProgressView().tint(.white)
            } else {
                Text(viewModel.submitTitle)
            }
        }
        .buttonStyle(.primary)
        .disabled(!viewModel.canSubmit)
    }

    private var switchModeRow: some View {
        HStack(spacing: Spacing.xxs) {
            Text(viewModel.mode == .signIn ? "New here?" : "Already have an account?")
                .foregroundStyle(Theme.ink)
            Button(viewModel.mode == .signIn ? "Create an account" : "Sign in") {
                viewModel.toggleMode()
            }
            .fontWeight(.semibold)
            .foregroundStyle(Theme.accentText)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    private func passwordSubmitted() {
        if viewModel.mode == .register {
            focusedField = .displayName
        } else {
            submit()
        }
    }

    private func submit() {
        focusedField = nil
        Task { await viewModel.submit() }
    }
}

#Preview("Sign in") {
    let container = AppContainer.preview(signedInAs: nil)
    AuthView(viewModel: container.makeAuthViewModel(mode: .signIn))
        .appEnvironment(container)
}

#Preview("Register") {
    let container = AppContainer.preview(signedInAs: nil)
    AuthView(viewModel: container.makeAuthViewModel(mode: .register))
        .appEnvironment(container)
}
