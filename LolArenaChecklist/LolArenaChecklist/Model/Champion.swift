//
//  Champion.swift
//
//  Created by Tunx on 20/10/25.
//

import Foundation

struct Champion: Identifiable, Sendable {
    var id: String { key }
    let key: String
    let name: String
    let tags: [String]
    let imageFullName: String

    func imageURL(version: String = "13.24.1") -> URL? {
        let baseUrl = "https://ddragon.leagueoflegends.com/cdn/\(version)/img/champion/"
        return URL(string: baseUrl + imageFullName)
    }
}
