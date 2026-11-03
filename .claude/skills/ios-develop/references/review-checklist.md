# Review checklist

Run through this before you say a change is done. If an item fails, fix it or tell the user why you left it.

## Structure
- [ ] Each new top-level type is in its own file, and the file name matches the type (`Type+Purpose.swift` for extensions).
- [ ] New files are in the right folder (`Core/…`, `DesignSystem/`, `Features/<Area>/<Screen>/`, `Components/`).
- [ ] No file grew past ~200 lines without a good reason; no `body` is a wall of nested stacks.
- [ ] `project.pbxproj` was not edited to add files (folder-synchronized groups pick them up).

## MVVM
- [ ] Views contain no business logic, no repository or `URLSession` calls, and no domain state in `@State`.
- [ ] The view model does not `import SwiftUI`; its state is `private(set)`; user actions are methods.
- [ ] The view model's `init` only stores dependencies; loading starts from `.task`.
- [ ] Loading/error/content use `Loadable` and the view handles every case, including empty results.
- [ ] App-wide state (session, mode) is read from `SessionStore`, not copied into view models.

## SOLID
- [ ] The view model depends on role-based protocols, received through `init` (no singletons, no concrete `Remote…` types).
- [ ] New concrete types are created only in `AppContainer`.
- [ ] Mock and remote repositories honour the same contract (filters, sorting, errors).
- [ ] Protocols are small; nothing depends on methods it doesn't use.

## Swift
- [ ] Names follow the Swift API Design Guidelines; booleans read as assertions; acronyms uniformly cased.
- [ ] Access control is as tight as possible; classes are `final`.
- [ ] No force unwraps, `try!`, or empty `catch {}` in app code.
- [ ] `async/await` only — no completion handlers, Combine, or `DispatchQueue.main`.
- [ ] Money is `Decimal`; user-facing strings are localizable literals; no stringly-typed identifiers.
- [ ] Colours, spacing and radii come from `DesignSystem`, not literals.

## Quality
- [ ] Every new view has `#Preview`s (loaded, plus empty/error where relevant) built from mocks.
- [ ] Icon-only buttons have accessibility labels.
- [ ] View-model tests cover happy path, empty and failure (or you told the user the test target is missing).
- [ ] `xcodebuild … build` succeeds with no new warnings, and you reported the real result.
