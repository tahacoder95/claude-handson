import PhotosUI
import SwiftUI

/// Create or edit a listing.
struct ListingEditorView: View {
    @State private var viewModel: ListingEditorViewModel
    let onSaved: (Listing) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var pickerItems: [PhotosPickerItem] = []

    init(viewModel: ListingEditorViewModel, onSaved: @escaping (Listing) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    PhotoPickerStrip(
                        existingPhotos: viewModel.draft.existingPhotos,
                        newPhotos: viewModel.draft.newPhotos,
                        category: viewModel.draft.category,
                        remainingSlots: viewModel.draft.remainingPhotoSlots,
                        isProcessing: viewModel.isProcessingPhotos,
                        pickerItems: $pickerItems,
                        onRemoveExisting: viewModel.removeExistingPhoto,
                        onRemoveNew: viewModel.removeNewPhoto,
                    )
                    detailsFields
                    ConditionPicker(selection: $viewModel.draft.condition)
                    FormField(label: "Pickup location", message: viewModel.issues[.location]) {
                        TextField("e.g. Dubai Marina, Dubai", text: $viewModel.draft.location)
                            .textContentType(.addressCity)
                    }
                }
                .padding(Spacing.l)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(viewModel.isSaving)
                }
            }
            .safeAreaInset(edge: .bottom) { saveButton }
            .onChange(of: pickerItems) { _, items in
                Task { await loadPickedPhotos(items) }
            }
        }
        .interactiveDismissDisabled(viewModel.isSaving)
    }

    // MARK: - Sections

    @ViewBuilder
    private var detailsFields: some View {
        FormField(label: "Title", message: viewModel.issues[.title]) {
            TextField("What are you selling?", text: $viewModel.draft.title)
        }
        FormField(label: "Description") {
            TextField("Condition, age, what's included", text: $viewModel.draft.details, axis: .vertical)
                .lineLimit(3...6)
        }
        FormField(label: "Price", message: viewModel.issues[.price]) {
            HStack(spacing: Spacing.xs) {
                Text("AED")
                    .font(.headline)
                    .foregroundStyle(Theme.textSecondary)
                TextField("0", text: $viewModel.draft.priceText)
                    .keyboardType(.numberPad)
            }
        }
        FormField(label: "Category") {
            Picker("Category", selection: $viewModel.draft.category) {
                ForEach(ListingCategory.allCases) { category in
                    Label(category.title, systemImage: category.symbolName).tag(category)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(Theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            if viewModel.isSaving {
                ProgressView().tint(.white)
            } else {
                Text(viewModel.saveTitle)
            }
        }
        .buttonStyle(.primary)
        .disabled(viewModel.isSaving || viewModel.isProcessingPhotos)
        .padding(.horizontal, Spacing.l)
        .padding(.bottom, Spacing.xs)
    }

    // MARK: - Actions

    private func save() async {
        guard let listing = await viewModel.save() else { return }
        onSaved(listing)
        dismiss()
    }

    /// Loading picked photos needs PhotosUI, so it stays in the view; the view model gets plain data.
    private func loadPickedPhotos(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        var photos: [Data] = []
        for item in items {
            // A photo that can't be read (e.g. still downloading from iCloud) is skipped.
            if let data = try? await item.loadTransferable(type: Data.self) {
                photos.append(data)
            }
        }
        pickerItems = []
        viewModel.addPhotos(photos)
    }
}

#Preview("New") {
    let container = AppContainer.preview()
    ListingEditorView(viewModel: container.makeListingEditorViewModel(mode: .create)) { _ in }
        .appEnvironment(container)
}

#Preview("Edit") {
    let container = AppContainer.preview()
    ListingEditorView(viewModel: container.makeListingEditorViewModel(mode: .edit(SampleData.listings()[11]))) { _ in }
        .appEnvironment(container)
}
