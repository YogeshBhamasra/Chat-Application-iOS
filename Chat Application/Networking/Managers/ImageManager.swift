//
//  ImageManager.swift
//  Chat Application
//
//  Created by Yogesh Rao on 02/06/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import UIKit
import SwiftUI

enum DownloadError: Error {
    case dataCorrupt
    case failedToDownload
}

class ObservableImages: ObservableObject {
    private var images: [String  : UIImage] = [:]
    func addImages(key: String, value: UIImage) {
        images[key] = value
    }
    func getImage(key: String) -> UIImage? {
        return images[key]
    }
}

class ImageManager {
    
    let imageCache = NSCache<NSURL, UIImage>()
    static let shared = ImageManager()
    private init() {}
    @ObservedObject var images: ObservableImages = ObservableImages()
    func downloadImage(urlString: String, completion: @escaping ((Result<UIImage, Error>) -> Void)) {
        if urlString == "" {
            return
        }
        let url = URL(string: urlString)!
        if let image = imageCache.object(forKey: url as NSURL) {
            images.addImages(key: urlString, value: image)
            completion(.success(image))
        } else {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,
                        200...299 ~= httpResponse.statusCode,
                        error == nil,
                        let data else {
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(DownloadError.failedToDownload))
                    }
                    return
                }
                guard let image = UIImage(data: data) else {
                    completion(.failure(DownloadError.dataCorrupt))
                    return
                }
                self?.images.addImages(key: urlString, value: image)
                self?.imageCache.setObject(image, forKey: url as NSURL)
                completion(.success(image))
            }
            .resume()
        }
    }
}
