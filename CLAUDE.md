# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.
See [README.md](README.md) for project setup, build environments, git conventions, CI/CD, and localization.

> Before building, always run `xcodegen generate` to regenerate the `.xcodeproj` from `project.yml`.

## Module Map

`CorePackage` is split into three targets (flat for now — no per-feature split yet):
- **DesignSystem** — reusable visual components with no domain-model knowledge
- **Domain** — models and Managers (stateful orchestrators, e.g. `WishCreationManager`, `WishLibraryManager`)
- **Feature** — SwiftUI views + view models

```
Feature → Domain
Feature → DesignSystem
```

Both Domain and Feature also depend on the external `swift-dependencies` package (see DI below).
Domain and Feature modules should have corresponding unit test targets.

## Key Technologies

- **Language**: Swift 6.0 (strict concurrency)
- **UI**: SwiftUI
- **DI**: [pointfreeco/swift-dependencies](https://github.com/pointfreeco/swift-dependencies) — the
  real Point-Free package (matches what's used in production apps like Mapzu), not a custom
  reimplementation. `@Dependency(\.wishCreationManager) private var creationManager` in a ViewModel;
  a dependency is registered via a `DependencyKey` (`liveValue`/`testValue`/`previewValue`) + an
  extension on `DependencyValues`.
  For a **stateful** dependency (a `@MainActor` Manager that must stay the same instance across
  screens, unlike the library's typical stateless-client use case): register the key on a **separate
  `struct ...Key: DependencyKey`** (not `extension Manager: DependencyKey` directly on the
  `@MainActor` class — that fails to compile with "conformance crosses into main actor-isolated
  code"), with `static var liveValue: Manager { @MainActor get { Manager() } }`. The library caches
  `liveValue` after first access, so this computed property still yields a singleton — no
  `nonisolated(unsafe)` / `MainActor.assumeIsolated` needed anywhere
- **Navigation**: System `NavigationStack` / `NavigationPath` / `navigationDestination`, system nav
  bar and back button (including collapsing header and Liquid Glass behavior) — no custom Router.
  Pepco's `@Routable`/`@Presentable` Router was deliberately not ported: it assumes a fully custom
  nav bar/toolbar (its `NavigationPageView` hides the system nav bar) plus Snackbar/TabBar
  infrastructure this app doesn't have — adopting it would fight the system navigation this app wants
- **Testing**: XCTest unit tests
- **Code Quality**: SwiftLint via the `SwiftLintBuildToolPlugin` plugin (from
  [SimplyDanny/SwiftLintPlugins](https://github.com/SimplyDanny/SwiftLintPlugins)), attached to
  every `CorePackage` target in `Package.swift`. Config lives at `Packages/CorePackage/.swiftlint.yml`
  (ported from Pepco's ruleset). Runs automatically as part of every build — no separate command needed

## Architecture Quick Reference

- **ViewModels**: `@MainActor @Observable final class {Feature}ViewModel`
- **Views**: `struct {Feature}View: View` — co-located with their ViewModel in the same file
- **Navigation**: `@State`/`fileprivate var navigateToX` on the ViewModel, bound via
  `$viewModel.navigateToX` to `.navigationDestination(isPresented:)` on the View — no router layer.
  A property bound two-way from the View (e.g. any `navigateToX`) must be plain `fileprivate var`,
  not `private(set) fileprivate var` — the View needs to write it back to `false` on pop
- **Dependencies**: `@Dependency(\.managerName) private var manager` in the ViewModel (see DI above)
- **Managers**: Stateful `@MainActor` orchestrators in Domain (`WishCreationManager` for the
  in-progress draft, `WishLibraryManager` for saved wishes), each resolved through `@Dependency`.
  Since they aren't `@Observable` (that would force the unsafe-singleton workaround above), a
  ViewModel that displays a Manager's field must copy it into its own `@Observable` property on
  `didAppear()`/mutation — reading `viewModel.creationManager.selectedPackage` directly in `body`
  won't trigger a re-render
- **State**: `enum ViewState` driven rendering where useful; simple `@Observable` state otherwise

## Common Commands

```bash
# Required after any project.yml change
xcodegen generate
```

## Code Style

SwiftLint enforces the baseline style. Beyond that:

- `guard` exits go on their own line inside the braces
- `defer { }` bodies must span multiple lines — never `defer { cleanup() }` on one line
- Closure arguments are always written on multiple lines — never inlined:
  ```swift
  Foo(
      completion: { result in
          handle(result)
      }
  )
  ```
- Use blank lines to visually separate logical steps within a function body
- `switch` case return values go on a new line, never inline with `case`
- `import` statements sorted alphabetically (`@testable` does not affect sort order)
- Floating-point literals for `CGFloat`/`Double`/`Float`: `24.0` not `24`
- For complex computed properties where ternary is not applicable, use `if/else` with implicit
  return rather than `guard` with early return:
  ```swift
  var isHighlighted: Bool {
      if case let .selected(id) = state, id == self.id {
          true
      } else {
          false
      }
  }
  ```

### View Modifiers

Do not introduce a custom `ViewModifier` type unless it is reused in multiple places. For a
single use case, apply the modifiers directly on the view.

### Foundation Extensions

Before adding an extension on a Foundation type, check `Packages/CorePackage/Sources/Utils` for
an existing one. For a single use case, avoid a global extension entirely — either inline the
logic or write a `private` extension in the same file.

## Conventions

- ViewModel action handlers are named `did{Something}` (e.g. `didTapButton`, `didPullToRefresh`)
  and are `internal` (for testability) or `fileprivate`
- View and ViewModel are colocated in the same file; `fileprivate` is the access boundary:
  - `fileprivate var` — View can read and write
  - `private(set) fileprivate var` — View can read, only ViewModel writes
  - `fileprivate let` — constant readable by the View
- Views use `{View}_Preview: PreviewProvider` for previews (migration to `#Preview` macros is planned but not yet started)

## Code Review

For AI code review instructions (used by CI on every MR/PR), see @.claude/REVIEW.md
