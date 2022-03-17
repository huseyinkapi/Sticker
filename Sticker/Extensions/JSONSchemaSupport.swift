import Foundation

public typealias Stickers = [StickerCategory]

extension Array where Element == Stickers.Element {
  init(data: Data) throws {
    self = try newJSONDecoder().decode(Stickers.self, from: data)
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

  func jsonData() throws -> Data {
    try newJSONEncoder().encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    String(data: try jsonData(), encoding: encoding)
  }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
  let decoder = JSONDecoder()
  if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
    decoder.dateDecodingStrategy = .iso8601
  }
  return decoder
}

func newJSONEncoder() -> JSONEncoder {
  let encoder = JSONEncoder()
  if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
    encoder.dateEncodingStrategy = .iso8601
  }
  return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
  func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else {
        completionHandler(nil, response, error)
        return
      }
      completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
    }
  }

  func stickersTask(with url: URL, completionHandler: @escaping (Stickers?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    codableTask(with: url, completionHandler: completionHandler)
  }
}
