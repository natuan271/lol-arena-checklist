//
//  ChampionListView.swift
//
//  Created by Tunx on 20/10/25.
//

import SwiftUI

struct ChampionListView: View {
    @StateObject private var viewModel = ChampionViewModel()
    let grid = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    filterView()
                    listChampionView()
                }
                .padding(.bottom, 16)
            }
            .accentColor(.yellow)
            .preferredColorScheme(.dark)
            .navigationTitle("Completed \(viewModel.completedChampionKeys.count)/\(viewModel.champions.count)")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                toolbarView()
            }
            .searchable(text: $viewModel.searchText)
            .alert(
                "Are you sure you want to proceed with this action?",
                isPresented: $viewModel.showingConfirmationAlert
            ) {
                Button(role: .destructive) {
                    viewModel.removeCompleted()
                }
            }
            .task {
                await viewModel.fetchVersion()
                await viewModel.fetchChampions()
            }
        }
    }

    @ViewBuilder
    func filterView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("All") {
                    viewModel.selectedTag = nil
                }
                .buttonStyle(FilterButtonStyle(is: viewModel.selectedTag == nil && (viewModel.completedTag || viewModel.selectedTag == nil)))
                .glassEffect()

                Button("Completed") {
                    viewModel.completedTag.toggle()

                }
                .buttonStyle(FilterButtonStyle(is: viewModel.completedTag))
                .glassEffect()

                ForEach(viewModel.allTags, id: \.self) { tag in
                    Button(tag) {
                        if viewModel.selectedTag == tag {
                            viewModel.selectedTag = nil
                        } else {
                            viewModel.selectedTag = tag
                        }
                    }
                    .buttonStyle(FilterButtonStyle(is: viewModel.selectedTag == tag))
                    .glassEffect()
                }
            }
        }
    }

    @ViewBuilder
    func listChampionView() -> some View {
        LazyVGrid(columns: grid, spacing: 12) {
            ForEach(viewModel.filteredChampions) { champion in
                let completed = viewModel.completedChampionKeys.contains(champion.key)
                ChampionView(
                    champion: champion,
                    imageVersion: viewModel.latestVersion,
                    completed: completed,
                    isSelecting: viewModel.isMultipleSelecting
                ) { action in
                    if let action {
                        viewModel.toggleComplete(for: champion, as: !action)
                    } else {
                        viewModel.toggleComplete(for: champion, as: completed)
                    }
                }
            }
        }
        .padding(4)
    }

    @ToolbarContentBuilder
    func toolbarView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Image("arena_rank")
                .resizable()
                .offset(x: CGFloat(-viewModel.getRank()) * 1.12 * 24)
                .scaledToFill()
                .scaleEffect(2)
                .clipShape(Circle())
        }
        ToolbarItem(placement: .topBarTrailing) {
            if !viewModel.isMultipleSelecting {
                Button {
                    viewModel.showingConfirmationDialog = true
                } label: {
                    Image(systemName: "checkmark.circle.badge.xmark.fill")
                }
                .confirmationDialog("",
                    isPresented: $viewModel.showingConfirmationDialog
                ) {
                    Button("Select Multiple", role: .confirm) {
                        Task {
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            viewModel.isMultipleSelecting = true
                        }
                    }
                    Button("Uncheck all", role: .destructive) {
                        viewModel.showingConfirmationAlert = true
                    }
                    Button("Cancel", role: .cancel) {
                        viewModel.showingConfirmationDialog = false
                    }
                }
            } else {
                Button {
                    viewModel.isMultipleSelecting = false
                } label: {
                    Text("Done")
                }
            }
        }
    }
}
