import SwiftUI

/// Lets the demo host point phones at the laptop or hosted server, or go fully offline.
struct ServerSettingsView: View {
    @State private var viewModel: ServerSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ServerSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    FormField(label: "Server address", message: viewModel.validationMessage) {
                        TextField(ServerSettings.defaultBaseURLString, text: $viewModel.baseURLText)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .disabled(viewModel.usesMockBackend)
                    .opacity(viewModel.usesMockBackend ? 0.5 : 1)

                    Text("On a phone, use the address `npm start` prints under “on your network”.")
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)

                    Toggle(isOn: $viewModel.usesMockBackend) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Offline demo mode")
                                .font(.headline)
                            Text("Use built-in sample data instead of the server. Sign in with omar / demo123.")
                                .font(.footnote)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(Spacing.m)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.fieldRadius))
                }
                .padding(Spacing.xl)
            }
            .background(Theme.background)
            .navigationTitle("Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

#Preview {
    let container = AppContainer.preview(signedInAs: nil)
    ServerSettingsView(viewModel: container.makeServerSettingsViewModel())
        .appEnvironment(container)
}
