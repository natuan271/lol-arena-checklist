//
//  ChampionWrapper.swift
//
//  Created by Tunx on 20/10/25.
//

import Foundation

struct ChampionWrapper: Codable {
    let data: [String: ChampionData]
}

struct ChampionData: Codable {
    let key: String
    let name: String
    let tags: [String]
    let image: ImageData    // Thêm phần image
}

struct ImageData: Codable {
    let full: String
}
