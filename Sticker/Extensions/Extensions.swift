import Foundation
import UIKit

extension JSONSerialization {
  enum ParseError: Error {
    case encodeError
    case decodeError
  }

  static func encode<T: Encodable>(obj: T) -> Result<Data, ParseError> {
    let encoder = PropertyListEncoder()
    do {
      let data = try encoder.encode(obj)
      return .success(data)
    } catch {
      Logger.error(error)
      return .failure(.encodeError)
    }
  }

  static func decode<T: Decodable>(obj: T, data: Data) -> Result<T, ParseError> {
    let decoder = PropertyListDecoder()
    do {
      let ttt = try decoder.decode(T.self, from: data)
      return .success(ttt)
    } catch {
      Logger.error(error)
      return .failure(.decodeError)
    }
  }
}

/// converting %20 etc in URL
extension String {
  func encodedURLString() -> String {
    replacingOccurrences(of: " ", with: "%20")
  }

  func decodedURLString() -> String {
    replacingOccurrences(of: "%20", with: " ")
  }
}

extension UICollectionView {
  func register(types: [CellType]) {
    types.forEach { type in
      let nib = UINib(nibName: type.rawValue, bundle: nil)
      self.register(nib, forCellWithReuseIdentifier: type.rawValue)
    }
  }

  func dequeue<T: UICollectionViewCell>(type: T.Type, cellType: CellType, indexPath: IndexPath) -> T {
    dequeueReusableCell(withReuseIdentifier: cellType.id, for: indexPath) as! T
  }
}

public extension Array {
  subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
    guard index >= 0, index < endIndex else {
      return defaultValue()
    }

    return self[index]
  }

  subscript(safeIndex index: Int) -> Element? {
    guard index >= 0, index < endIndex else {
      return nil
    }
    return self[index]
  }
}

extension UIColor {

  public static var defaultBgColor = UIColor(red: 0.99, green: 0.26, blue: 0.51, alpha: 1.00)
  public static var defaultSecondaryColor = UIColor(red: 0.94, green: 0.93, blue: 1.00, alpha: 1.00)
  public static var defaultTextColor = UIColor(red: 0.18, green: 0.08, blue: 0.40, alpha: 1.00)
  public static var defaultSecondaryTextColor = UIColor(red: 0.45, green: 0.41, blue: 0.53, alpha: 1.00)

  convenience init(hexString: String, alpha: CGFloat = 1.0) {
    let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    if hexString.hasPrefix("#") {
      scanner.scanLocation = 1
    }
    var color: UInt32 = 0
    scanner.scanHexInt32(&color)
    let mask = 0x000000FF
    let rrr = Int(color >> 16) & mask
    let ggg = Int(color >> 8) & mask
    let bbb = Int(color) & mask
    let red   = CGFloat(rrr) / 255.0
    let green = CGFloat(ggg) / 255.0
    let blue  = CGFloat(bbb) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
  func toHexString() -> String {
    var rrr: CGFloat = 0
    var ggg: CGFloat = 0
    var bbb: CGFloat = 0
    var aaa: CGFloat = 0
    getRed(&rrr, green: &ggg, blue: &bbb, alpha: &aaa)
    let rgb: Int = (Int)(rrr * 255) << 16 | (Int)(ggg * 255) << 8 | (Int)(bbb * 255) << 0
    return String(format: "#%06x", rgb)
  }
}

extension UINavigationController {

  func popViewControllerWithHandler(isAnimated: Bool, completion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    self.popViewController(animated: isAnimated)
    CATransaction.commit()
  }

  func pushViewController(viewController: UIViewController, isAnimated: Bool, completion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    self.pushViewController(viewController, animated: isAnimated)
    CATransaction.commit()
  }
}
