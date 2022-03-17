import Foundation
import Kingfisher
import UIKit
import FlexColorPicker

public class StickerEditImageModel: NSObject {
  public let editRect: CGRect?
  public let angle: CGFloat
  public let stickerImages: [(state: StickerImageState, index: Int)]?
  init(editRect: CGRect?, angle: CGFloat, stickerImages: [(state: StickerImageState, index: Int)]?) {
    self.editRect = editRect
    self.angle = angle
    self.stickerImages = stickerImages
    super.init()
  }
}

class ImageTransformViewController: UIViewController {
  var theImage: UIImage?
  var originalImage: UIImage?
  var editRect: CGRect?
  var editImage: UIImage?
  var currentEditModel: StickerEditImageModel?
  var containerView: UIView!
  var imageView: UIImageView!
  var stickersContainer: UIView!
  var stickers: [UIView] = []
  var shouldLayout = true
  var angle: CGFloat = 0.0
  var lastEditedSticker: ImageStickerView?
  var colorPickerController: DefaultColorPickerViewController?
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet var categoryCollectionView: UICollectionView!
  @IBOutlet var thumbnailCollectionView: UICollectionView!
  @IBOutlet var colorCollectionView: UICollectionView!
  @IBOutlet weak var modallyCloseBtn: UIButton!
  @IBOutlet weak var modallyShareBtn: UIButton!
  @IBOutlet weak var modallyDownloadBtn: UIButton!
  @IBAction func modallyShareBtn(_ sender: Any) {
    shareAction()
  }
  @IBAction func modallyDownloadBtn(_ sender: Any) {
    downloadAction()
  }

  func modallyCloseAction() {
    if ImageTransform.shared.isPresentedWithImagePicker {
      self.dismiss(animated: ImageTransform.shared.isAnimated, completion: nil)
    } else {
      self.dismiss(animated: ImageTransform.shared.isAnimated, completion: ImageTransform.shared.onDidTapCloseButton)
    }
  }

  @IBAction func modallyCloseBtn(_ sender: Any) {
    if(UserDefaultsConfig.closeAlertShown == false){
        UserDefaultsConfig.closeAlertShown = true
        showModalCloseAlert()
    }else{
        modallyCloseAction()
    }
    /*
    if !self.stickersContainer.subviews.isEmpty {
      showModalCloseAlert()
    } else {
      modallyCloseAction()
    }
 */
  }

  static let defaultCell = UICollectionViewCell()
  var categoryLayout: CenteredCollectionViewFlowLayout!

  override func viewDidLoad() {
    super.viewDidLoad()
    modallyCloseBtn.isHidden = ImageTransform.shared.isModallyPresented ? false : true
    modallyShareBtn.isHidden = ImageTransform.shared.isModallyPresented ? false : true
    modallyDownloadBtn.isHidden = ImageTransform.shared.isModallyPresented ? false : true
    modallyShareBtn.layer.masksToBounds = true
    modallyShareBtn.layer.cornerRadius = 16
    modallyDownloadBtn.layer.masksToBounds = true
    modallyDownloadBtn.layer.cornerRadius = 16

    let value = UIInterfaceOrientation.portrait.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
    firstSetAndCheck()
    self.setupUI()
    configureNavigationBar()
    configureColors()
    ImageTransform.webservice.getResources { result in
      DispatchQueue.main.async {
        self.activityControl.stopAnimating()
      }
      switch result {
      case .failure(let error):
        Logger.error(error)
        self.present(UIAlertController(), animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
      case .success(let stickers):
        DispatchQueue.main.async {
          self.categoryData = stickers
          self.thumbnailCollectionView.reloadData()
        }
      }
    }
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard self.shouldLayout else {
      return
    }
    self.shouldLayout = false
    DispatchQueue.main.async {
      // self.scrollView.frame = self.view.bounds
      self.resetContainerViewFrame()
    }
  }

  var activityControl: UIActivityIndicatorView = {
    let activity = UIActivityIndicatorView()
    activity.translatesAutoresizingMaskIntoConstraints = false
    activity.backgroundColor = UIColor.black.withAlphaComponent(0.51)
    activity.color = UIColor.white
    return activity
  }()

  var imageSize: CGSize {
    if self.angle == -90 || self.angle == -270 {
      return CGSize(width: self.originalImage!.size.height, height: self.originalImage!.size.width)
    }
    return self.originalImage!.size
  }

  public override var prefersStatusBarHidden: Bool {
    return true
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  var currentCategoryIndex = 0 {
    didSet {
      DispatchQueue.main.async {
        self.categoryCollectionView.reloadData()
        self.categoryCollectionView.layoutSubviews()
        self.thumbnailCollectionView.reloadData()
        self.thumbnailCollectionView.layoutSubviews()
      }
    }
  }

  var currentStickerThumbnailIndex = 0 {
    didSet {
      self.thumbnailCollectionView.reloadData()
      self.thumbnailCollectionView.layoutSubviews()
    }
  }

  var categoryData: Stickers = [] {
    didSet {
      self.categoryCollectionView.reloadData()
    }
  }

  @objc func closeButtonAction() {
    
    if(UserDefaultsConfig.closeAlertShown == false){
        UserDefaultsConfig.closeAlertShown = true
        showCloseAlert()
    }else{
        closeAction()
    }

/*
    if !self.stickersContainer.subviews.isEmpty {
      showCloseAlert()
    } else {
      closeAction()
    }
    */
  }

  private func showCloseAlert() {
    let alert = UIAlertController(
      title: ImageTransform.configure.closeAlertTitleText,
      message: ImageTransform.configure.closeAlertMessageText,
      preferredStyle: .alert
    )
    let action = UIAlertAction(title: ImageTransform.configure.closeAlertOkButtonText, style: .default, handler: { action in
      self.closeAction()
    })
    alert.addAction(action)
    alert.addAction(UIAlertAction(title: ImageTransform.configure.closeAlertCancelButtonText, style: .destructive, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  private func showModalCloseAlert() {
    let alert = UIAlertController(
      title: ImageTransform.configure.closeAlertTitleText,
      message: ImageTransform.configure.closeAlertMessageText,
      preferredStyle: .alert
    )
    let action = UIAlertAction(title: ImageTransform.configure.closeAlertOkButtonText, style: .default, handler: { action in
      self.modallyCloseAction()
    })
    alert.addAction(action)
    alert.addAction(UIAlertAction(title: ImageTransform.configure.closeAlertCancelButtonText, style: .destructive, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  func closeAction() {
    if ImageTransform.shared.isModulePushed {
      self.navigationController?.popViewControllerWithHandler(
        isAnimated: ImageTransform.shared.isAnimated,
        completion: ImageTransform.shared.onDidTapCloseButton!
      )
    } else {
      if ImageTransform.shared.isPresentedWithImagePicker {
        self.dismiss(animated: ImageTransform.shared.isAnimated, completion: nil)
        ImageTransform.shared.removeChild()
      } else {
        self.dismiss(animated: ImageTransform.shared.isAnimated, completion: ImageTransform.shared.onDidTapCloseButton)
        ImageTransform.shared.removeChild()
      }
    }
  }

  @objc func shareButtonAction() {
    shareAction()
  }

  @objc func downloadButtonAction() {
    downloadAction()
  }


  func shareAction() {
    var stickerImages: [(StickerImageState, Int)] = []
    for (index, view) in self.stickersContainer.subviews.enumerated() {
      if let tss = view as? ImageStickerView {
        stickerImages.append((tss.state, index))
      }
    }
    let image = self.buildImage()
    let imageToShare = [ image ]
    let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
    self.present(activityViewController, animated: true, completion: nil)
  }

  func downloadAction() {
    var stickerImages: [(StickerImageState, Int)] = []
    for (index, view) in self.stickersContainer.subviews.enumerated() {
      if let tss = view as? ImageStickerView {
        stickerImages.append((tss.state, index))
      }
    }
    let image = self.buildImage()
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  // MARK: - Add image to Library
  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      // we got back an error!
      let acc = UIAlertController(
        title: ImageTransform.configure.alertSavingErrorText,
        message: error.localizedDescription,
        preferredStyle: .alert
      )
      acc.addAction(UIAlertAction(title: ImageTransform.configure.alertButtonTitle, style: .default))
      present(acc, animated: true)
    } else {
      let acc = UIAlertController(
        title: ImageTransform.configure.alertTitle,
        message: ImageTransform.configure.alertMessageText,
        preferredStyle: .alert
      )
      acc.addAction(UIAlertAction(title: ImageTransform.configure.alertButtonTitle, style: .default))
      present(acc, animated: true)
    }
  }

  func setBackgroundImage(with image: UIImage) {
    self.imageView.image = image
  }

  func userDidChangeCategory() {
    guard
      let layout = categoryCollectionView.collectionViewLayout as? CenteredCollectionViewFlowLayout,
      let index = layout.currentCenteredPage else { return }
    currentCategoryIndex = index
  }

  func scrollCategory(index: Int) {
    categoryLayout.scrollToPage(index: index, animated: true)
  }

  override var shouldAutorotate: Bool {
    return false
  }
}

extension ImageTransformViewController {
  func resetContainerViewFrame() {
    self.scrollView.setZoomScale(1, animated: true)
    self.imageView.image = self.editImage

    let editSize = self.editRect!.size
    let scrollViewSize = self.scrollView.frame.size
    let ratio = min(scrollViewSize.width / editSize.width, scrollViewSize.height / editSize.height)
    let www = ratio * editSize.width * self.scrollView.zoomScale
    let hhh = ratio * editSize.height * self.scrollView.zoomScale
    self.containerView.frame = CGRect(
      x: max(0, (scrollViewSize.width - www) / 2),
      y: max(0, (scrollViewSize.height - hhh) / 2),
      width: www,
      height: hhh
    )

    let scaleImageOrigin = CGPoint(x: -self.editRect!.origin.x * ratio, y: -self.editRect!.origin.y * ratio)
    let scaleImageSize = CGSize(width: self.imageSize.width * ratio, height: self.imageSize.height * ratio)
    self.imageView.frame = CGRect(origin: scaleImageOrigin, size: scaleImageSize)

    self.stickersContainer.frame = self.imageView.frame

    // Optimization for long pictures.
    //   if (self.editRect.height / self.editRect.width) > (self.view.frame.height / self.view.frame.width * 1.1) {
    if (self.editRect!.height / self.editRect!.width)
      > (self.scrollView.frame.height / self.scrollView.frame.width * 1.1) {  // HK TODO
      let widthScale = self.view.frame.width / www
      self.scrollView.maximumZoomScale = widthScale
      self.scrollView.zoomScale = widthScale
      self.scrollView.contentOffset = .zero
    } else if self.editRect!.width / self.editRect!.height > 1 {
      // self.scrollView.maximumZoomScale = max(3, self.view.frame.height / h)  // HK TODO
      self.scrollView.maximumZoomScale = max(3, self.scrollView.frame.height / hhh)  // HK TODO
    }
  }

  func rotationImageView() {
    let transform = CGAffineTransform(rotationAngle: self.angle.toPi)
    self.imageView.transform = transform
    self.stickersContainer.transform = transform
  }

  func buildImage() -> UIImage {
    // let imageSize = self.originalImage.size
    UIGraphicsBeginImageContextWithOptions(self.editImage!.size, false, self.editImage!.scale)
    self.editImage!.draw(at: .zero)
    if !self.stickersContainer.subviews.isEmpty, let context = UIGraphicsGetCurrentContext() {
      let scale = self.imageSize.width / self.stickersContainer.frame.width
      self.stickersContainer.subviews.forEach { view in
        (view as? StickerViewAdditional)?.resetState()
      }
      context.concatenate(CGAffineTransform(scaleX: scale, y: scale))
      self.stickersContainer.layer.render(in: context)
      context.concatenate(CGAffineTransform(scaleX: 1 / scale, y: 1 / scale))
    }
    let temp = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    guard let cgi = temp?.cgImage else {
      return self.editImage!
    }
    return UIImage(cgImage: cgi, scale: self.editImage!.scale, orientation: .up)
  }

  func getStickerOriginFrame(_ size: CGSize) -> CGRect {
    let scale = self.scrollView.zoomScale
    // Calculate the display rect of container view.
    let xxx = (self.scrollView.contentOffset.x - self.containerView.frame.minX) / scale
    let yyy = (self.scrollView.contentOffset.y - self.containerView.frame.minY) / scale

    let www = self.scrollView.frame.width / scale
    let hhh = self.scrollView.frame.height / scale

    // let w = self.stickersContainer.frame.width / scale
    // let h = self.stickersContainer.frame.height / scale

    // Convert to text stickers container view.
    let rrr = self.containerView.convert(CGRect(x: xxx, y: yyy, width: www, height: hhh), to: self.stickersContainer)
    let originFrame = CGRect(
      x: rrr.minX + (rrr.width - size.width) / 2,
      y: rrr.minY + (rrr.height - size.height) / 2,
      width: size.width,
      height: size.height
    )
    return originFrame
  }

  /// Add image sticker
  func addImageStickerView(_ url: URL) {
    activityControl.startAnimating()
    StickerCacheManager.shared.downloadImageFrom(url: url) { [weak self] image in
      self?.activityControl.stopAnimating()
      if image != nil {
        let scale = self?.scrollView.zoomScale
        let size = ImageStickerView.calculateSize(image: image!, width: (self?.view.frame.width)!)
        let originFrame = self?.getStickerOriginFrame(size)
        let imageSticker = ImageStickerView(
          image: image!,
          originScale: 1 / scale!,
          originAngle: -(self?.angle)!,
          originFrame: originFrame!
        )
        self?.stickersContainer.addSubview(imageSticker)
        imageSticker.frame = originFrame!
        self?.view.layoutIfNeeded()
        self?.configImageSticker(imageSticker)
        self?.lastEditedSticker = imageSticker
      }
    }
  }

  func configImageSticker(_ imageSticker: ImageStickerView) {
    imageSticker.delegate = self
    self.scrollView.pinchGestureRecognizer?.require(toFail: imageSticker.pinchGes)
    self.scrollView.panGestureRecognizer.require(toFail: imageSticker.panGes)
  }

  func reCalculateStickersFrame(_ oldSize: CGSize, _ oldAngle: CGFloat, _ newAngle: CGFloat) {
    let currSize = self.stickersContainer.frame.size
    let scale: CGFloat
    if Int(newAngle - oldAngle) % 180 == 0 {
      scale = currSize.width / oldSize.width
    } else {
      scale = currSize.height / oldSize.width
    }

    self.stickersContainer.subviews.forEach { view in
      (view as? StickerViewAdditional)?.addScale(scale)
    }
  }

  func changeColor(with hex: String) {
    if lastEditedSticker != nil {
      lastEditedSticker?.imageView.image = lastEditedSticker?.imageView.image?.withRenderingMode(.alwaysTemplate)
      lastEditedSticker?.imageView.tintColor = UIColor(hexString: hex)
    }
  }

  func changeColor(with color: UIColor) {
    if lastEditedSticker != nil {
      lastEditedSticker?.imageView.image = lastEditedSticker?.imageView.image?.withRenderingMode(.alwaysTemplate)
      lastEditedSticker?.imageView.tintColor = color
    }
  }
}

extension ImageTransformViewController: ColorPickerDelegate {

  func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
    // code to handle that user selected a color without confirmed it yet (may change selected color)
  }

  func colorPicker(_ colorPicker: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
    // code to handle that user has confirmed selected color
    changeColor(with: confirmedColor)
    navigationController?.popViewController(animated: true)
  }
}
