// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let categoryLocalizations = try CategoryLocalizations(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.categoryLocalizationsTask(with: url) { categoryLocalizations, response, error in
//     if let categoryLocalizations = categoryLocalizations {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - CategoryLocalizations

public struct CategoryLocalizations: Codable {
  public let tr, th, zh, vi: String
  public let pt, ru, id, es: String
  public let ar, ja, fr: String

  enum CodingKeys: String, CodingKey, CaseIterable {
    case tr, th, zh, vi, pt, ru, id, es, ar, ja, fr
  }
}

// MARK: CategoryLocalizations convenience initializers and mutators

extension CategoryLocalizations {
  init(data: Data) throws {
    self = try newJSONDecoder().decode(CategoryLocalizations.self, from: data)
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
    tr: String? = nil,
    th: String? = nil,
    zh: String? = nil,
    vi: String? = nil,
    pt: String? = nil,
    ru: String? = nil,
    id: String? = nil,
    es: String? = nil,
    ar: String? = nil,
    ja: String? = nil,
    fr: String? = nil
  ) -> CategoryLocalizations {
    CategoryLocalizations(
      tr: tr ?? self.tr,
      th: th ?? self.th,
      zh: zh ?? self.zh,
      vi: vi ?? self.vi,
      pt: pt ?? self.pt,
      ru: ru ?? self.ru,
      id: id ?? self.id,
      es: es ?? self.es,
      ar: ar ?? self.ar,
      ja: ja ?? self.ja,
      fr: fr ?? self.fr
    )
  }

  func jsonData() throws -> Data {
    try newJSONEncoder().encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    String(data: try jsonData(), encoding: encoding)
  }
}
