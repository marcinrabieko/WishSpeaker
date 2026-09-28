# Project README

## Getting started

To build the project locally, you need to generate the `.xcodeproj` file using [xcodegen](https://github.com/yonaskolb/XcodeGen). Follow these steps:

1. Ensure you have `xcodegen` installed. If not, you can install it via [Homebrew](https://brew.sh/):
    ```bash
    brew install xcodegen
    ```
2. Navigate to the root directory of the project in your terminal.
3. Run the following command to generate the `.xcodeproj` file:
    ```bash
    xcodegen generate
    ```
4. Open the generated `.xcodeproj` file with Xcode:
    ```bash
    open WishSpeaker.xcodeproj
    ```

### Notes
- **Info.plist** files: These files are generated from the xcodegen configuration. Any modifications to the `Info.plist` should be made in the `project.yml` file, not directly in the generated files.
- **Entitlements** files: Separate `.entitlements` files are pre-configured per environment. These files are already included and do not require additional generation. Be sure to use the appropriate entitlements file when adding or modifying permissions for specific environments.

Always use xcodegen to regenerate the project file when any changes are made to the `project.yml` configuration. Avoid manually editing the `.xcodeproj` file, as these changes will be overwritten during regeneration.

## Git and CI

### Branching Strategy
- develop is a main branch
- every bigger feature should be created on new branch

## Project Organisation, Targets and Schemes

### Modularization
- **Infrastructure** packages (e.g. `UI`, `Utils`, `Storage`) have no dependencies on other modules.
- **Domain** modules sit above infrastructure and define models, client protocols, business rules,
  and Managers (stateful orchestrators) for a specific feature area. Models and client protocols
  reflect the contracts (request/response shapes and endpoints) of the backend.
- **Feature** modules depend on domain modules and assemble the final user-facing views and view models,
  injecting Managers from their domain module into the ViewModels that need them. Every View/ViewModel
  pair must be registered in the feature's view factory so the navigation system can present it.
- The **DesignSystem** module is independent of domain models and defines its own model layer;
  feature modules are responsible for binding design system models with domain models.

## Conventions

### Architecture
- ViewModel action handlers are named `did{Something}` (e.g. `didTapButton`, `didPullToRefresh`)
- View and ViewModel are colocated in separate file; public is the access boundary between them
- Views use `{View}_Preview: PreviewProvider` for Xcode previews

### Navigation
- Every ViewModel is declared `@MainActor @Observable final class`.
- ViewModels that are pushed onto the navigation stack use the `@Routable` macro; those
  presented in a sheet use `@Presentable`. Navigation calls (`router?.push()`,
  `router?.presentInSheet()`) are always made from the ViewModel, never from the View.

### HTTP Communication
- All network calls go through **domain-defined clients** injected via `@Dependency` — never
  directly via `httpClient` or `URLSession` from a ViewModel or Manager.
- Clients are defined in Domain modules and own the `httpClient` dependency internally.
  Their protocols are what ViewModels and Managers depend on.

### Accessibility Identifiers
- Add `.accessibilityIdentifier` to all visual and interactive components — buttons, inputs,
  tappable cells, cards, images, named containers. Default to adding them; omission is the exception.
- Use names from the Figma "IDs For Testing" spec when available. If there is no spec, align with
  QA or derive a name consistent with existing identifiers in the same area.
- Use `accessibilityElement(children:)` (`.contain`, `.ignore`, `.combine`) to structure the
  accessibility tree — identifiers on leaf nodes alone are not sufficient for nested components.
- Verify coverage with **Xcode → Open Developer Tool → Accessibility Inspector** before submitting.
- Use SwiftUI's built-in accessibility modifiers directly — do not introduce custom `ViewModifier`
  types for accessibility.

### Code Style

#### Formatting
- Braced bodies must always span multiple lines — never compress `defer { … }`,
  `guard … else { … }`, or `return { … }` onto a single line.
- Use blank lines to visually separate logical steps within a function body.

#### View Modifiers
- Do not introduce a custom `ViewModifier` unless it is reused in multiple places.
  For a single use case, apply the modifiers directly on the view.

#### Foundation Extensions
- Before writing a new extension on a Foundation type, check
  `Packages/CorePackage/Sources/Utils` for an existing one.
- For a single use case, avoid a global extension entirely — either inline the logic
  or write a `private` extension in the same file.

#### Computed Properties
- For complex flag computations where the ternary operator is not applicable, use `if/else`
  with implicit return — not `guard` with an early return:
  ```swift
  var isHighlighted: Bool {
      if case let .selected(id) = state, id == self.id {
          true
      } else {
          false
      }
  }
  ```

## AI Tooling

This project uses [Claude Code](https://claude.ai/code) as the primary AI coding assistant.

`CLAUDE.md` (project root) and `.claude/REVIEW.md` are tracked in git and serve as the source
of truth for AI instructions — architecture rules, code style, review priorities. Keep them
updated as conventions evolve.

### AI Code Review

Every finished feature triggers an automated Claude-based code review as part of the CI pipeline.
The review output is **suggestion-only** — it does not block — but the **Issues** and
**Suggestions** sections are worth reading through before the feature is finished. You can ask at the end if you can make review.
