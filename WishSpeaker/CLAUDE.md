# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.
See [README.md](README.md) for project setup, build environments, git conventions, CI/CD, and localization.

> Before building, always run `xcodegen generate` to regenerate the `.xcodeproj` from `project.yml`.

## Module Map

`CorePackage` is split into three tiers:
- **Infrastructure** — business-agnostic utilities (Storage, Networking, Navigation, UI, …)
- **Domain** — models, client protocols, business rules, and Managers (stateful orchestrators) per feature area
- **Feature** — SwiftUI views, view models

```
Feature → Domain → Infrastructure
Feature → DesignSystem
```

Domain and Feature modules should have corresponding unit test targets.

## Key Technologies

- **Language**: Swift 6.0 (strict concurrency)
- **UI**: SwiftUI + Combine
- **DI**: swift-dependencies (`@Dependency` macro)
- **Navigation**: Custom `@Routable` / `@Presentable` macros + Router — `router` and presentation
  context are `weak` optionals by design; they are always set by the navigation system before the
  view appears, so `router?.push()` optional chaining is idiomatic and guard-unwrapping is not required
- **Storage**: `StorageClient` (UserDefaults / Keychain / Memory / Ephemeral backends)
- **Networking**: Custom `Networking` module
- **Testing**: XCTest unit tests + snapshot tests (`PreviewSnapshotTesting`)
- **Code Quality**: SwiftLint plugin (per-target)

## Architecture Quick Reference

- **ViewModels**: `@MainActor @Observable final class {Feature}ViewModel`
- **Views**: `struct {Feature}View: View` — co-located with their ViewModel
- **Navigation**: `@Routable` (push) or `@Presentable` (sheet) on ViewModel → `router?.push()` / `router?.presentInSheet()`
- **Dependencies**: `@ObservationIgnored @Dependency(\.clientName) private var client`
- **Clients**: Struct-based, defined in Domain modules; injected via `DependencyKey` (analogous to
  SwiftUI's `EnvironmentKey` — register a default/live value, override in tests or previews)
- **Managers**: Stateful orchestrators in Domain modules — injected into ViewModels from Feature modules
- **State**: `enum ViewState` driven rendering; optimistic updates for write operations
- **Errors**: Propagate via `throw`; present to user via snackbar or `StateView`

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
