import UIKit
import Kingfisher

protocol StickerViewDelegate: NSObject {
  func stickerBeginOperation(_ sticker: UIView)
  func stickerOnOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer)
  func stickerEndOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer)
  func stickerDidTap(_ sticker: UIView)
}

protocol StickerViewAdditional: NSObject {
  var gesIsEnabled: Bool { get set }
  func resetState()
  func moveToAshbin()
  func addScale(_ scale: CGFloat)
}

class ImageStickerView: UIView, StickerViewAdditional {
  static let edgeInset: CGFloat = 30
  static let borderWidth = 1 / UIScreen.main.scale
  weak var delegate: StickerViewDelegate?
  var firstLayout = true
  var gesIsEnabled = true
  let originScale: CGFloat
  var originAngle: CGFloat
  var originFrame: CGRect
  var originTransform: CGAffineTransform = .identity
  var image: UIImage
  var pinchGes: UIPinchGestureRecognizer!
  var tapGes: UITapGestureRecognizer!
  var panGes: UIPanGestureRecognizer!
  var timer: Timer?
  var imageView: UIImageView!
  var totalTranslationPoint: CGPoint = .zero
  var gesTranslationPoint: CGPoint = .zero
  var gesRotation: CGFloat = 0
  var gesScale: CGFloat = 1
  var onOperation = false
  var dashViewBorder = CAShapeLayer()
  var dashContainerView = UIView()
  let imageCache = NSCache<NSString, AnyObject>()
  var removeBtn: UIButton!
  var mirrorBtn: UIButton!

  var state: StickerImageState {
    return StickerImageState(
      image: self.image,
      originScale: self.originScale,
      originAngle: self.originAngle,
      originFrame: self.originFrame,
      gesScale: self.gesScale,
      gesRotation: self.gesRotation,
      totalTranslationPoint: self.totalTranslationPoint
    )
  }

  deinit {
    self.cleanTimer()
  }

  convenience init(from state: StickerImageState) {
    self.init(
      image: state.image,
      originScale: state.originScale,
      originAngle: state.originAngle,
      originFrame: state.originFrame,
      gesScale: state.gesScale,
      gesRotation: state.gesRotation,
      totalTranslationPoint: state.totalTranslationPoint,
      showBorder: false
    )
  }

  init(image: UIImage, originScale: CGFloat, originAngle: CGFloat, originFrame: CGRect, gesScale: CGFloat = 1, gesRotation: CGFloat = 0, totalTranslationPoint: CGPoint = .zero, showBorder: Bool = true) {
    self.image = image
    self.originScale = originScale
    self.originAngle = originAngle
    self.originFrame = originFrame
    super.init(frame: .zero)
    self.gesScale = gesScale
    self.gesRotation = gesRotation
    self.totalTranslationPoint = totalTranslationPoint
    self.layer.borderWidth = 5
    self.layer.borderColor = UIColor.clear.cgColor
    self.imageView = UIImageView(image: image)
    self.imageView.contentMode = .scaleAspectFit
    self.imageView.clipsToBounds = true
    self.addSubview(self.imageView)
    self.tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    self.addGestureRecognizer(self.tapGes)
    self.pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
    self.pinchGes.delegate = self
    self.addGestureRecognizer(self.pinchGes)
    let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))
    rotationGes.delegate = self
    self.addGestureRecognizer(rotationGes)
    self.panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
    self.panGes.delegate = self
    self.addGestureRecognizer(self.panGes)
    self.tapGes.require(toFail: self.panGes)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    guard self.firstLayout else {
      return
    }
    self.transform = self.transform.rotated(by: self.originAngle.toPi)
    if self.totalTranslationPoint != .zero {
      if self.originAngle == 90 {
        self.transform = self.transform.translatedBy(x: self.totalTranslationPoint.y, y: -self.totalTranslationPoint.x)
      } else if self.originAngle == 180 {
        self.transform = self.transform.translatedBy(x: -self.totalTranslationPoint.x, y: -self.totalTranslationPoint.y)
      } else if self.originAngle == 270 {
        self.transform = self.transform.translatedBy(x: -self.totalTranslationPoint.y, y: self.totalTranslationPoint.x)
      } else {
        self.transform = self.transform.translatedBy(x: self.totalTranslationPoint.x, y: self.totalTranslationPoint.y)
      }
    }
    self.transform = self.transform.scaledBy(x: self.originScale, y: self.originScale)
    self.originTransform = self.transform
    if self.gesScale != 1 {
      self.transform = self.transform.scaledBy(x: self.gesScale, y: self.gesScale)
    }
    if self.gesRotation != 0 {
      self.transform = self.transform.rotated(by: self.gesRotation)
    }
    self.firstLayout = false
    self.imageView.frame = self.bounds.insetBy(dx: ImageStickerView.edgeInset, dy: ImageStickerView.edgeInset)
    addDashContainerView()
    setupButtons()
    self.startTimer()
  }

  @objc func tapAction(_ ges: UITapGestureRecognizer) {
    guard self.gesIsEnabled else { return }
    self.superview?.bringSubviewToFront(self)
    self.delegate?.stickerDidTap(self)
    self.startTimer()
  }

  @objc func pinchAction(_ ges: UIPinchGestureRecognizer) {
    guard self.gesIsEnabled else { return }
    self.gesScale *= ges.scale
    ges.scale = 1
    if ges.state == .began {
      self.setOperation(true)
    } else if ges.state == .changed {
      self.updateTransform()
    } else if ges.state == .ended || ges.state == .cancelled {
      self.setOperation(false)
    }
  }

  @objc func rotationAction(_ ges: UIRotationGestureRecognizer) {
    guard self.gesIsEnabled else { return }
    self.gesRotation += ges.rotation
    ges.rotation = 0
    if ges.state == .began {
      self.setOperation(true)
    } else if ges.state == .changed {
      self.updateTransform()
    } else if ges.state == .ended || ges.state == .cancelled {
      self.setOperation(false)
    }
  }

  @objc func panAction(_ ges: UIPanGestureRecognizer) {
    guard self.gesIsEnabled else { return }
    let point = ges.translation(in: self.superview)
    self.gesTranslationPoint = CGPoint(x: point.x / self.originScale, y: point.y / self.originScale)
    if ges.state == .began {
      self.setOperation(true)
    } else if ges.state == .changed {
      self.updateTransform()
    } else if ges.state == .ended || ges.state == .cancelled {
      self.totalTranslationPoint.x += point.x
      self.totalTranslationPoint.y += point.y
      self.setOperation(false)
      if self.originAngle == 90 {
        self.originTransform =
          self.originTransform.translatedBy(x: self.gesTranslationPoint.y, y: -self.gesTranslationPoint.x)
      } else if self.originAngle == 180 {
        self.originTransform =
          self.originTransform.translatedBy(x: -self.gesTranslationPoint.x, y: -self.gesTranslationPoint.y)
      } else if self.originAngle == 270 {
        self.originTransform =
          self.originTransform.translatedBy(x: -self.gesTranslationPoint.y, y: self.gesTranslationPoint.x)
      } else {
        self.originTransform =
          self.originTransform.translatedBy(x: self.gesTranslationPoint.x, y: self.gesTranslationPoint.y)
      }
      self.gesTranslationPoint = .zero
    }
  }

  func setOperation(_ isOn: Bool) {
    if isOn, !self.onOperation {
      self.onOperation = true
      self.cleanTimer()
      self.superview?.bringSubviewToFront(self)
      self.delegate?.stickerBeginOperation(self)
    } else if !isOn, self.onOperation {
      self.onOperation = false
      self.startTimer()
      self.delegate?.stickerEndOperation(self, panGes: self.panGes)
    }
  }

  func updateTransform() {
    var transform = self.originTransform
    if self.originAngle == 90 {
      transform = transform.translatedBy(x: self.gesTranslationPoint.y, y: -self.gesTranslationPoint.x)
    } else if self.originAngle == 180 {
      transform = transform.translatedBy(x: -self.gesTranslationPoint.x, y: -self.gesTranslationPoint.y)
    } else if self.originAngle == 270 {
      transform = transform.translatedBy(x: -self.gesTranslationPoint.y, y: self.gesTranslationPoint.x)
    } else {
      transform = transform.translatedBy(x: self.gesTranslationPoint.x, y: self.gesTranslationPoint.y)
    }
    transform = transform.scaledBy(x: self.gesScale, y: self.gesScale)
    transform = transform.rotated(by: self.gesRotation)
    self.transform = transform
    self.delegate?.stickerOnOperation(self, panGes: self.panGes)
  }

  @objc func hideBorder() {
    self.cleanTimer()
    hideSelection()
  }

  func startTimer() {
    self.cleanTimer()
    showSelection()
    self.timer = Timer.scheduledTimer(
      timeInterval: 4,
      target: self,
      selector: #selector(hideBorder),
      userInfo: nil,
      repeats: false
    )
    RunLoop.current.add(self.timer!, forMode: .default)
  }

  func showSelection() {
    dashContainerView.layer.addSublayer(dashViewBorder)
    removeBtn.alpha = 1.0
    mirrorBtn.alpha = 1.0
  }

  func hideSelection() {
    dashViewBorder.removeFromSuperlayer()
    removeBtn.alpha = 0.0
    mirrorBtn.alpha = 0.0
  }

  func cleanTimer() {
    self.timer?.invalidate()
    self.timer = nil
  }

  func resetState() {
    self.onOperation = false
    self.cleanTimer()
    self.hideBorder()
  }

  func moveToAshbin() {
    self.cleanTimer()
    self.removeFromSuperview()
  }

  func addScale(_ scale: CGFloat) {
    self.transform = self.transform.scaledBy(x: 1 / self.originScale, y: 1 / self.originScale)
    self.transform = self.transform.scaledBy(x: 1 / self.gesScale, y: 1 / self.gesScale)
    self.transform = self.transform.rotated(by: -self.gesRotation)
    var origin = self.frame.origin
    origin.x *= scale
    origin.y *= scale
    let newSize = CGSize(width: self.frame.width * scale, height: self.frame.height * scale)
    let newOrigin = CGPoint(
      x: self.frame.minX + (self.frame.width - newSize.width) / 2,
      y: self.frame.minY + (self.frame.height - newSize.height) / 2
    )
    let diffX: CGFloat = (origin.x - newOrigin.x)
    let diffY: CGFloat = (origin.y - newOrigin.y)
    if self.originAngle == 90 {
      self.transform = self.transform.translatedBy(x: diffY, y: -diffX)
      self.originTransform =
        self.originTransform.translatedBy(x: diffY / self.originScale, y: -diffX / self.originScale)
    } else if self.originAngle == 180 {
      self.transform = self.transform.translatedBy(x: -diffX, y: -diffY)
      self.originTransform =
        self.originTransform.translatedBy(x: -diffX / self.originScale, y: -diffY / self.originScale)
    } else if self.originAngle == 270 {
      self.transform = self.transform.translatedBy(x: -diffY, y: diffX)
      self.originTransform =
        self.originTransform.translatedBy(x: -diffY / self.originScale, y: diffX / self.originScale)
    } else {
      self.transform = self.transform.translatedBy(x: diffX, y: diffY)
      self.originTransform = self.originTransform.translatedBy(x: diffX / self.originScale, y: diffY / self.originScale)
    }
    self.totalTranslationPoint.x += diffX
    self.totalTranslationPoint.y += diffY
    self.transform = self.transform.scaledBy(x: scale, y: scale)
    self.transform = self.transform.scaledBy(x: self.originScale, y: self.originScale)
    self.transform = self.transform.scaledBy(x: self.gesScale, y: self.gesScale)
    self.transform = self.transform.rotated(by: self.gesRotation)
    self.gesScale *= scale
  }

  class func calculateSize(image: UIImage, width: CGFloat) -> CGSize {
    let maxSide = width / 2
    let minSide: CGFloat = 100
    let whRatio = image.size.width / image.size.height
    var size: CGSize = .zero
    if whRatio >= 1 {
      let www = min(maxSide, max(minSide, image.size.width))
      let hhh = www / whRatio
      size = CGSize(width: www, height: hhh)
    } else {
      let hhh = min(maxSide, max(minSide, image.size.width))
      let www = hhh * whRatio
      size = CGSize(width: www, height: hhh)
    }
    size.width += ImageStickerView.edgeInset * 2
    size.height += ImageStickerView.edgeInset * 2
    return size
  }
}

extension ImageStickerView: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if touch.view == removeBtn || touch.view == mirrorBtn {
      return false
    }
    return true
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

extension ImageStickerView {
  func setupButtons() {
    removeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
    removeBtn.setImage(ImageTransform.image(named: "ic_close"), for: .normal)
    removeBtn.addTarget(self, action: #selector(removeBtnClick), for: .touchUpInside)
    self.addSubview(removeBtn)

    mirrorBtn = UIButton.init(frame: CGRect.init(x: 0, y: self.bounds.maxY - 30, width: 30, height: 30))
    mirrorBtn.setImage(ImageTransform.image(named: "ic_s"), for: .normal)
    mirrorBtn.addTarget(self, action: #selector(mirrorBtnClick), for: .touchUpInside)
    self.addSubview(mirrorBtn)
  }

  @objc func removeBtnClick() {
    self.removeFromSuperview()
  }

  @objc func sizerBtnClick() {
    transform = transform.scaledBy(x: 2.0, y: 2.0)
    self.transform = transform
    self.gesScale *= 2.0
  }

  @objc func mirrorBtnClick() {
    let imageWillBeMirrored = self.imageView.image
    self.image = imageWillBeMirrored!.withHorizontallyFlippedOrientation()
    self.imageView.image = self.image
  }

  @objc func rotateBtnClick() {
    self.gesRotation -= CGFloat(Double.pi / 2)
    self.setOperation(true)
    self.updateTransform()
    self.setOperation(false)
  }

  func addDashContainerView() {
    dashContainerView.frame = self.bounds.insetBy(
      dx: ImageStickerView.edgeInset - 15,
      dy: ImageStickerView.edgeInset - 15
    )
    dashContainerView.backgroundColor = UIColor.clear
    self.addSubview(dashContainerView)
    dashViewBorder.strokeColor = UIColor.white.cgColor
    dashViewBorder.lineDashPattern = [10, 4]
    dashViewBorder.lineWidth = 2.5
    dashViewBorder.frame = dashContainerView.bounds
    dashViewBorder.fillColor = nil
    dashViewBorder.path = UIBezierPath(rect: dashContainerView.bounds).cgPath
  }
}
