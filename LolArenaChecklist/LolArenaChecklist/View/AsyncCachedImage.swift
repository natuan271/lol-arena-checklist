//
//  AsyncCachedImage.swift
//  LolArenaChecklist
//
//  Created by Tunx on 20/10/25.
//

import SwiftUI

struct AsyncCachedImage: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Image

    init(url: URL, placeholder: Image = Image(systemName: "photo")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        content
            .onAppear { loader.load() }
            .onDisappear { loader.cancel() }
    }

    private var content: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
                    .resizable()
                    .foregroundColor(.gray)
                    .opacity(0.3)
            }
        }
    }
}
