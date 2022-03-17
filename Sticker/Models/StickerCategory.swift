// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let stickerCategoryElement = try StickerCategoryElement(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.stickerCategoryElementTask(with: url) { stickerCategoryElement, response, error in
//     if let stickerCategoryElement = stickerCategoryElement {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - StickerCategoryElement

public struct StickerCategory: Codable {
  public init(categoryName: String, categoryLocalizations: CategoryLocalizations, stickers: [Sticker]) {
    self.categoryName = categoryName
    self.categoryLocalizations = categoryLocalizations
    self.stickers = stickers
  }

  public let categoryName: String
  public let categoryLocalizations: CategoryLocalizations
  public let stickers: [Sticker]

  enum CodingKeys: String, CodingKey {
    case categoryName = "category_name"
    case categoryLocalizations = "category_localizations"
    case stickers
  }

  public var localizedName: String {
    let pre = Locale.preferredLanguages[0]
    let codes = CategoryLocalizations.CodingKeys.allCases.map(\.rawValue)
    let dictionary = categoryLocalizations.dictionary
    var value = categoryName
    for code in codes {
      if pre.contains(code) {
        value = dictionary[code] as? String ?? categoryName
      }
    }
    return value
  }
}

// MARK: StickerCategoryElement convenience initializers and mutators

extension StickerCategory {
  init(data: Data) throws {
    self = try newJSONDecoder().decode(StickerCategory.self, from: data)
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
    categoryName: String? = nil,
    categoryLocalizations: CategoryLocalizations? = nil,
    stickers: [Sticker]? = nil
  ) -> StickerCategory {
    StickerCategory(
      categoryName: categoryName ?? self.categoryName,
      categoryLocalizations: categoryLocalizations ?? self.categoryLocalizations,
      stickers: stickers ?? self.stickers
    )
  }

  func jsonData() throws -> Data {
    try newJSONEncoder().encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    String(data: try jsonData(), encoding: encoding)
  }
}
