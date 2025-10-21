struct ChampionListView: View {
    @StateObject private var viewModel = ChampionViewModel()
    let grid = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button("All") {
                                viewModel.selectedTag = nil
                            }
                            .tagFilterStyle(selected: viewModel.selectedTag == nil && (viewModel.completedTag || viewModel.selectedTag == nil))
                            .glassEffect()

                            Button("Completed") {
                                viewModel.completedTag.toggle()
                            }
                            .tagFilterStyle(selected: viewModel.completedTag)
                            .glassEffect()

                            ForEach(viewModel.allTags, id: \.self) { tag in
                                Button(tag) {
                                    if viewModel.selectedTag == tag {
                                        viewModel.selectedTag = nil
                                    } else {
                                        viewModel.selectedTag = tag
                                    }
                                }
                                .tagFilterStyle(selected: viewModel.selectedTag == tag)
                                .glassEffect()
                            }
                        }
                        .padding(.horizontal)
                    }

                    LazyVGrid(columns: grid, spacing: 12) {
                        ForEach(viewModel.filteredChampions) { champion in
                            VStack {
                                if let url = champion.imageURL(version: viewModel.latestVersion) {
                                    AsyncCachedImage(url: url)
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .overlay {
                                if viewModel.completedChampionKeys.contains(champion.key) {
                                    Rectangle()
                                    .stroke(.yellow, lineWidth: 1)
                                    .overlay(alignment: .bottom) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .bold()
                                            .foregroundStyle(.yellow)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Circle())
                                            .frame(width: 64, height: 64)
                                            .offset(y: 32)
                                    }
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                Menu {
                                    Button {
                                        viewModel.toggleComplete(for: champion)
                                    } label: {
                                        Text("Mark as completed")
                                    }
                                    Button {
                                        viewModel.toggleComplete(for: champion)
                                    } label: {
                                        Text("Mark as uncompleted")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundStyle(.white)
                                        .padding(8)
                                        .clipShape(.circle)
                                        .glassEffect()
                                        .padding(2)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Completed \(viewModel.completedChampionKeys.count) champs")
            .searchable(text: $viewModel.searchText)
            .task {
                await viewModel.fetchVersion()
                await viewModel.fetchChampions()
            }
        }
    }
}

extension View {
    func tagFilterStyle(selected: Bool) -> some View {
        self
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                if selected {
                    Capsule().fill(.white.opacity(0.5))
                } else {
                    Capsule().fill(.ultraThickMaterial)
                }
            }
            .foregroundStyle(selected ? .black : .secondary)
            .clipShape(Capsule())
    }
}
