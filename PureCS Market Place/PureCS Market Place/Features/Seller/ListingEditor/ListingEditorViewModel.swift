import Foundation
import Observation

@Observable
final class ListingEditorViewModel {
    let mode: ListingEditorMode
    var draft: ListingDraft
    private(set) var isSaving = false
    private(set) var isProcessingPhotos = false
    private(set) var hasAttemptedSave = false
    private(set) var errorMessage: String?

    private var removedPhotoIDs: [ListingPhoto.ID] = []
    private let repository: any ListingManaging
    private let imageCompressor: any ImageCompressing

    init(mode: ListingEditorMode, repository: any ListingManaging, imageCompressor: any ImageCompressing) {
        self.mode = mode
        self.repository = repository
        self.imageCompressor = imageCompressor
        switch mode {
        case .create: draft = ListingDraft()
        case .edit(let listing): draft = ListingDraft(listing: listing)
        }
    }

    // MARK: - State

    var title: String {
        if case .edit = mode { String(localized: "Edit Listing") } else { String(localized: "New Listing") }
    }

    var saveTitle: String {
        if case .edit = mode { String(localized: "Save Changes") } else { String(localized: "Post Listing") }
    }

    /// Validation messages appear only after the first save attempt, so the form doesn't start out red.
    var issues: [ListingDraft.Field: String] {
        hasAttemptedSave ? draft.issues : [:]
    }

    // MARK: - Intents

    func addPhotos(_ photos: [Data]) {
        isProcessingPhotos = true
        defer { isProcessingPhotos = false }
        for data in photos.prefix(draft.remainingPhotoSlots) {
            if let jpeg = imageCompressor.jpegData(from: data) {
                draft.newPhotos.append(PhotoAttachment(data: jpeg))
            }
        }
    }

    func removeExistingPhoto(_ photo: ListingPhoto) {
        draft.existingPhotos.removeAll { $0.id == photo.id }
        removedPhotoIDs.append(photo.id)
    }

    func removeNewPhoto(_ attachment: PhotoAttachment) {
        draft.newPhotos.removeAll { $0.id == attachment.id }
    }

    /// Returns the saved listing, or nil when validation or the request failed.
    func save() async -> Listing? {
        hasAttemptedSave = true
        errorMessage = nil
        guard let input = draft.makeInput(removedPhotoIDs: removedPhotoIDs) else { return nil }

        isSaving = true
        defer { isSaving = false }
        do {
            switch mode {
            case .create:
                return try await repository.createListing(input)
            case .edit(let listing):
                return try await repository.updateListing(id: listing.id, with: input)
            }
        } catch {
            errorMessage = error.userMessage
            return nil
        }
    }
}
