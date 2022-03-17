import Foundation
import UIKit

public enum CacheError: Error {
  case downloadError(String)
  case urlError
  case cachedResultIsNil(String)
  case dataConvertError
}

class StickerCacheManager {
  let stickerImageCache = NSCache<NSString, AnyObject>()
  static let shared = StickerCacheManager()
  func downloadImageFrom(url: URL, completion: @escaping (UIImage?) -> Void) {
    if let cachedImage = stickerImageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
      completion(cachedImage)
    } else {
      URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
          completion(nil)
          return
        }
        DispatchQueue.main.async {
          let imageToCache = UIImage(data: data)
          self.stickerImageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
          completion(imageToCache)
        }
      }
      .resume()
    }
  }
}

class JsonCacheManager {
  let stickerImageCache = NSCache<NSString, AnyObject>()
  static let shared = JsonCacheManager()
  private let fileManager = FileManager.default

  private lazy var mainDirectoryUrl: URL = {
    let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    return documentsUrl
  }()

  private var directoryForJson: URL {
    mainDirectoryUrl.appendingPathComponent("stickers.json")
  }

  func getFileURL() -> Result<URL, CacheError> {
    // return file path if already exists in cache directory
    guard !fileManager.fileExists(atPath: directoryForJson.path) else {
      return .success(directoryForJson)
    }
    let message = "No Cache has been found"
    Logger.warning(message)
    return .failure(CacheError.cachedResultIsNil(message))
  }

  func getData() -> Result<Data, CacheError> {
    if let url = try? getFileURL().get(),
    let data = try? Data(contentsOf: url) {
      return .success(data)
    }
    return .failure(CacheError.dataConvertError)
  }

  func saveFile(data: Data) {
    do {
      try data.write(to: directoryForJson)
    } catch {
      Logger.error(error)
    }
  }
  var doesFileExist: Bool {
    fileManager.fileExists(atPath: directoryForJson.path)
  }
}

enum JSON {
  static let encoder = JSONEncoder()
}

extension Encodable {
  subscript(key: String) -> Any? {
    dictionary[key]
  }

  var dictionary: [String: Any] {
    (try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self))) as? [String: Any] ?? [:]
  }
}
