//
//  ChampionViewModel.swift
//  LolArenaChecklist
//
//  Created by Tunx on 20/10/25.
//

import Foundation
import Combine

@MainActor
class ChampionViewModel: ObservableObject {
    @Published var champions: [Champion] = []
    @Published var filteredChampions: [Champion] = []

    @Published var completedChampionKeys: Set<String> = []

//    @Published var selectedItems: Set<String> = []

    @Published var searchText: String = "" {
        didSet { applyFilter() }
    }
    @Published var selectedTag: String? = nil {
        didSet { applyFilter() }
    }
    @Published var completedTag: Bool = false {
        didSet { applyFilter() }
    }
    @Published var showingConfirmationDialog: Bool = false
    @Published var showingConfirmationAlert: Bool = false

    @Published var isMultipleSelecting: Bool = false

    private let completedKey = "CompletedChampions"
    var latestVersion = ""

    init() {
        loadCompleted()
//        $searchText
//            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
//            .removeDuplicates()
//            .sink { [weak self] newValue in
//                self?.filterChampions(searchText: newValue)
//            }
//            .store(in: &cancellables)
    }

    var allTags: [String] {
        let tags = champions.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }

    private func applyFilter() {
        filteredChampions = champions.filter { champion in
            let matchesSearch = searchText.isEmpty || champion.name.localizedCaseInsensitiveContains(searchText)
            let matchesTag = selectedTag == nil || champion.tags.contains(selectedTag!)
            let matchesCompleted = !completedTag || completedChampionKeys.contains(champion.key)
            return matchesSearch && matchesTag && matchesCompleted
        }
    }
    func fetchVersion() async {
        do {
            guard let url = URL(string: "https://ddragon.leagueoflegends.com/api/versions.json") else {
                throw URLError(.badURL)
            }
            let (data, res) = try await URLSession.shared.data(from: url)
            guard let res = res as? HTTPURLResponse, (200..<300).contains(res.statusCode) else {
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode([String].self, from: data)

            guard let latestVersion = decoded.first else {
                throw URLError(.badServerResponse)
            }
            self.latestVersion = latestVersion
        } catch {
            print("Error decoding: \(error)")
        }
    }

    func fetchChampions() async {
        do {
            guard let url = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(latestVersion)/data/vi_VN/champion.json") else {
                throw URLError(.badURL)
            }
            let (data, res) = try await URLSession.shared.data(from: url)
            guard let res = res as? HTTPURLResponse, (200..<300).contains(res.statusCode) else {
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(ChampionWrapper.self, from: data)

            let champs = decoded.data.map {
                Champion(
                    key: $0.value.key,
                    name: $0.value.name,
                    tags: $0.value.tags,
                    imageFullName: $0.value.image.full
                )
            }.sorted { $0.name < $1.name }

            self.champions = champs
            self.filteredChampions = champs
        } catch {
            print("Error decoding: \(error)")
        }
    }

    func toggleComplete(for champion: Champion, as completed: Bool) {
        if completed {
            completedChampionKeys.remove(champion.key)
        } else {
            completedChampionKeys.insert(champion.key)
        }
        saveCompleted()
    }

    private func loadCompleted() {
        if let saved = UserDefaults.standard.array(forKey: completedKey) as? [String] {
            completedChampionKeys = Set(saved)
        }
    }

    func removeCompleted() {
        completedChampionKeys.removeAll()
        saveCompleted()
    }

    private func saveCompleted() {
        UserDefaults.standard.set(Array(completedChampionKeys), forKey: completedKey)
    }

    func getRank() -> Int {
        let count = completedChampionKeys.count
        switch count {
        case 0..<5: return -2
        case 5..<10: return -1
        case 10..<20: return 0
        case 20..<40: return 1
        case 40..<80: return 2
        default: return -2
        }
    }
}
