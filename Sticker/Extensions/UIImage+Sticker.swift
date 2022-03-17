import UIKit

extension UIImage {

  func rotate(orientation: UIImage.Orientation) -> UIImage {
    guard let imagRef = self.cgImage else {
      return self
    }
    let rect = CGRect(origin: .zero, size: CGSize(width: CGFloat(imagRef.width), height: CGFloat(imagRef.height)))

    var bnds = rect

    var transform = CGAffineTransform.identity

    switch orientation {
    case .up:
      return self
    case .upMirrored:
      transform = transform.translatedBy(x: rect.width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    case .down:
      transform = transform.translatedBy(x: rect.width, y: rect.height)
      transform = transform.rotated(by: .pi)
    case .downMirrored:
      transform = transform.translatedBy(x: 0, y: rect.height)
      transform = transform.scaledBy(x: 1, y: -1)
    case .left:
      bnds = swapRectWidthAndHeight(bnds)
      transform = transform.translatedBy(x: 0, y: rect.width)
      transform = transform.rotated(by: CGFloat.pi * 3 / 2)
    case .leftMirrored:
      bnds = swapRectWidthAndHeight(bnds)
      transform = transform.translatedBy(x: rect.height, y: rect.width)
      transform = transform.scaledBy(x: -1, y: 1)
      transform = transform.rotated(by: CGFloat.pi * 3 / 2)
    case .right:
      bnds = swapRectWidthAndHeight(bnds)
      transform = transform.translatedBy(x: rect.height, y: 0)
      transform = transform.rotated(by: CGFloat.pi / 2)
    case .rightMirrored:
      bnds = swapRectWidthAndHeight(bnds)
      transform = transform.scaledBy(x: -1, y: 1)
      transform = transform.rotated(by: CGFloat.pi / 2)
    @unknown default:
      return self
    }

    UIGraphicsBeginImageContext(bnds.size)
    let context = UIGraphicsGetCurrentContext()
    switch orientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      context?.scaleBy(x: -1, y: 1)
      context?.translateBy(x: -rect.height, y: 0)
    default:
      context?.scaleBy(x: 1, y: -1)
      context?.translateBy(x: 0, y: -rect.height)
    }
    context?.concatenate(transform)
    context?.draw(imagRef, in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage ?? self
  }

  func swapRectWidthAndHeight(_ rect: CGRect) -> CGRect {
    var rrr = rect
    rrr.size.width = rect.height
    rrr.size.height = rect.width
    return rrr
  }

  func rotate(degress: CGFloat) -> UIImage {
    let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
    let ttt = CGAffineTransform(rotationAngle: degress)
    rotatedViewBox.transform = ttt
    let rotatedSize = rotatedViewBox.frame.size

    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap = UIGraphicsGetCurrentContext()

    bitmap?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)

    bitmap?.rotate(by: degress)

    bitmap?.scaleBy(x: 1.0, y: -1.0)
    guard let cgImg = self.cgImage else {
      return self
    }
    bitmap?.draw(
    cgImg,
    in: CGRect(
      x: -self.size.width / 2,
      y: -self.size.height / 2,
      width: self.size.width,
      height: self.size.height
    )
    )

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage ?? self
  }

  func mosaicImage() -> UIImage? {
    guard let currCgImage = self.cgImage else {
      return nil
    }

    let currCiImage = CIImage(cgImage: currCgImage)
    let filter = CIFilter(name: "CIPixellate")
    filter?.setValue(currCiImage, forKey: kCIInputImageKey)
    filter?.setValue(20, forKey: kCIInputScaleKey)
    guard let outputImage = filter?.outputImage else { return nil }

    let context = CIContext()

    if let cgImg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: self.size)) {
      return UIImage(cgImage: cgImg)
    } else {
      return nil
    }
  }

  func resize(_ size: CGSize) -> UIImage? {
    if size.width <= 0 || size.height <= 0 {
      return nil
    }
    UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
    self.draw(in: CGRect(origin: .zero, size: size))
    let temp = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return temp
  }

  func toCIImage() -> CIImage? {
    var cii = self.ciImage
    if cii == nil, let cgg = self.cgImage {
      cii = CIImage(cgImage: cgg)
    }
    return cii
  }

  func clipImage(_ angle: CGFloat, _ editRect: CGRect) -> UIImage? {
    let aaa = ((Int(angle) % 360) - 360) % 360
    var newImage = self
    if aaa == -90 {
      newImage = self.rotate(orientation: .left)
    } else if aaa == -180 {
      newImage = self.rotate(orientation: .down)
    } else if aaa == -270 {
      newImage = self.rotate(orientation: .right)
    }
    guard editRect.size != newImage.size else {
      return newImage
    }
    let origin = CGPoint(x: -editRect.minX, y: -editRect.minY)
    UIGraphicsBeginImageContextWithOptions(editRect.size, false, newImage.scale)
    newImage.draw(at: origin)
    let temp = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    guard let cgi = temp?.cgImage else {
      return temp
    }
    let clipImage = UIImage(cgImage: cgi, scale: newImage.scale, orientation: .up)
    return clipImage
  }

  func blurImage(level: CGFloat) -> UIImage? {
    guard let ciImage = self.toCIImage() else {
      return nil
    }
    let blurFilter = CIFilter(name: "CIGaussianBlur")
    blurFilter?.setValue(ciImage, forKey: "inputImage")
    blurFilter?.setValue(level, forKey: "inputRadius")

    guard let outputImage = blurFilter?.outputImage else {
      return nil
    }
    let context = CIContext()
    guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else {
      return nil
    }
    return UIImage(cgImage: cgImage)
  }
}


extension CIImage {

  func toUIImage() -> UIImage? {
    let context = CIContext()
    guard let cgImage = context.createCGImage(self, from: self.extent) else {
      return nil
    }
    return UIImage(cgImage: cgImage)
  }
}
