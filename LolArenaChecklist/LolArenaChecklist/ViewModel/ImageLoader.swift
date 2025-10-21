//
//  ImageLoader.swift
//  LolArenaChecklist
//
//  Created by Tunx on 20/10/25.
//

import Combine
import Foundation
import UIKit

final class ImageCache {
    @MainActor static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var task: Task<Void, Never>?
    private let url: URL
    private var didLoad = false

    init(url: URL) {
        self.url = url
    }

    func load() {
        guard !didLoad else { return }

        // Check cache first
        if let cached = ImageCache.shared.image(forKey: url.absoluteString) {
            self.image = cached
            self.didLoad = true
            return
        }

        task = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let uiImage = UIImage(data: data) else {
                    print("Invalid image data \(url)")
                    return
                }
                ImageCache.shared.setImage(uiImage, forKey: url.absoluteString)
                self.image = uiImage
                self.didLoad = true
            } catch {
                print("Failed to load image: \(error.localizedDescription)")
                self.didLoad = false
            }
        }
    }

    func cancel() {
        task?.cancel()
    }
}
