// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let sticker = try Sticker(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.stickerTask(with: url) { sticker, response, error in
//     if let sticker = sticker {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - Sticker
public struct Sticker: Codable {
  public let stickerURL: String
  public let stickerThumbnailURL: String
  public let isColorChangable: Bool

  enum CodingKeys: String, CodingKey {
    case stickerURL = "sticker_url"
    case stickerThumbnailURL = "sticker_thumbnail_url"
    case isColorChangable = "is_color_changeable"
  }
}

// MARK: Sticker convenience initializers and mutators

extension Sticker {
  init(data: Data) throws {
    self = try newJSONDecoder().decode(Sticker.self, from: data)
  }

  init(_ json: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = json.data(using: encoding) else {
      throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
    }
    try self.init(data: data)
  }

  init(fromURL url: URL) throws {
    try self.init(data: try Data(contentsOf: url))
  }

  func with(
    stickerURL: String? = nil,
    stickerThumbnailURL: String? = nil,
    isColorChangable: Bool? = nil
  ) -> Sticker {
    return Sticker(
      stickerURL: stickerURL ?? self.stickerURL,
      stickerThumbnailURL: stickerThumbnailURL ?? self.stickerThumbnailURL,
      isColorChangable: isColorChangable ?? self.isColorChangable
    )
  }

  func jsonData() throws -> Data {
    return try newJSONEncoder().encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    return String(data: try self.jsonData(), encoding: encoding)
  }
}
