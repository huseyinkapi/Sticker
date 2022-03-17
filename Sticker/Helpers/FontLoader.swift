import Foundation
import UIKit

enum FontLoader {
  static func loadFont(with path: URL) -> Bool {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path.path)),
    let provider = CGDataProvider(data: data as CFData)
    else {
      return false
    }

    guard let font = CGFont(provider) else {
      return false
    }
    var error: Unmanaged<CFError>?

    let success = CTFontManagerRegisterGraphicsFont(font, &error)
    if !success {
      print("Error loading font. Font is possibly already registered.")
      return false
    }

    return true
  }
}
