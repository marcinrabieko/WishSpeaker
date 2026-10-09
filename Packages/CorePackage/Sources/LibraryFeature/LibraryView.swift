import DesignSystem
import Domain
import Localizations
import SharedFeatureComponents
import SwiftUI

public struct LibraryView: View {
    @State private var viewModel = LibraryViewModel()
    @State private var presentedWish: Wish?

    public init() {}

    public var body: some View {
        Group {
            if viewModel.savedWishes.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.savedWishes) { wish in
                        LibraryRow(
                            wish: wish,
                            onTap: { presentedWish = wish },
                            onConfirmDelete: { viewModel.didConfirmDelete(wish) }
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(
                            EdgeInsets(
                                top: WSSpacing.xxs,
                                leading: WSSpacing.horizontalPadding,
                                bottom: WSSpacing.xxs,
                                trailing: WSSpacing.horizontalPadding
                            )
                        )
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.top, WSSpacing.xs)
            }
        }
        .background(Color.wsBackground)
        .navigationTitle(L10n.libraryTitle)
        .navigationBarTitleDisplayMode(.large)
        .wsBackButton()
        .onAppear {
            viewModel.didAppear()
        }
        .navigationDestination(item: $presentedWish) { wish in
            WishResultView(wish: wish)
        }
    }

    private var emptyState: some View {
        VStack(spacing: WSSpacing.sm) {
            Spacer()

            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundColor(.wsSecondaryText.opacity(0.5))

            Text(L10n.libraryEmptyTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.wsPrimaryText)

            Text(L10n.libraryEmptySubtitle)
                .font(.system(size: 15))
                .foregroundColor(.wsSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, WSSpacing.lg)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

/// Owns its own swipe-to-delete confirmation state so the dialog is scoped to this row
/// instead of the whole List — attaching it at the List/screen level instead causes the
/// dialog's appearance to race the row's own swipe-removal animation (the row visibly
/// flickers back in while the dialog is still animating in).
private struct LibraryRow: View {
    let wish: Wish
    let onTap: () -> Void
    let onConfirmDelete: () -> Void

    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        WishLibraryCard(wish: wish, onTap: onTap)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    didSwipeToDelete()
                } label: {
                    Label(L10n.libraryDeleteButton, systemImage: "trash")
                }
                .tint(.wsPrimary)
            }
            .confirmationDialog(
                L10n.libraryDeleteConfirmationTitle,
                isPresented: $isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(L10n.libraryDeleteConfirmationDeleteButton, role: .destructive, action: onConfirmDelete)
                Button(L10n.libraryDeleteConfirmationCancelButton, role: .cancel) {}
            } message: {
                Text(L10n.libraryDeleteConfirmationMessage)
            }
    }

    private func didSwipeToDelete() {
        if wish.voiceAsset != nil || wish.videoAsset != nil {
            isShowingDeleteConfirmation = true
        } else {
            onConfirmDelete()
        }
    }
}
