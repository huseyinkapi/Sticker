//
//  StickerImageState.swift
//  Sticker
//
//  Created by Huseyin Kapi on 12.01.2021.
//

import Foundation
import UIKit

public class StickerImageState: NSObject {

  let image: UIImage
  let originScale: CGFloat
  let originAngle: CGFloat
  let originFrame: CGRect
  let gesScale: CGFloat
  let gesRotation: CGFloat
  let totalTranslationPoint: CGPoint

  init(image: UIImage, originScale: CGFloat, originAngle: CGFloat, originFrame: CGRect, gesScale: CGFloat, gesRotation: CGFloat, totalTranslationPoint: CGPoint) {
    self.image = image
    self.originScale = originScale
    self.originAngle = originAngle
    self.originFrame = originFrame
    self.gesScale = gesScale
    self.gesRotation = gesRotation
    self.totalTranslationPoint = totalTranslationPoint
    super.init()
  }
}
