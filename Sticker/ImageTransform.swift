import UIKit

public typealias EditFinishBlock = (UIImage, StickerEditImageModel) -> Void
public typealias DefaultListener = () -> Void

public class ImageTransform {
  let resourceURL: URL!
  let projectID: String!
  public static let configure = Configurations.shared
  public var stickerColors: [String]

  static var webservice: Webservice!
  public static var shared: ImageTransform!

  var onEditFinishBlock: EditFinishBlock?
  var onDidTapCloseButton: DefaultListener?
  var ondidViewOpened: DefaultListener?
  var onLoadFailed: DefaultListener?

  internal static var fontName: String?
  internal static var color: UIColor?
  internal static var bundle = Bundle(for: ImageTransform.self)
  let storyboard = UIStoryboard(name: "ImageTransform", bundle: bundle)

  var withCloseShareButtons: Bool = true
  var isModulePushed: Bool = false
  var isModallyPresented: Bool = false
  var isFullyPresented: Bool = false
  var isAnimated: Bool = false
  var isPresentedWithImagePicker: Bool = false
  public var stickerNavigationViewController: UINavigationController?
  public var currentPushedNavigationController: UINavigationController?
  public init(resourceURL: URL, projectID: String) {
    self.resourceURL = resourceURL
    self.projectID = projectID
    stickerColors = ["#FFFFFF", "#000000", "#C15B2E", "#2EC150", "#2E4AC1", "#C12E99", "ColorSelection"]
  }

  // MARK: - init methods
  public static func start(with: URL, projectID: String) -> ImageTransform {
    ImageTransform.shared = ImageTransform(resourceURL: with, projectID: projectID)
    ImageTransform.webservice = Webservice(url: with, projectID: projectID, delegate: ImageTransform.shared)
    shared.preloadResources()
    configure.configureFonts()
    configure.configureColors()
    configure.configureTitleTexts()
    configure.configureActionTexts()
    configure.configurePhotoSavedAlertTexts()
    configure.configureSelectionOfImageSourceText()
    configure.configureCloseAlertTexts()
    return shared
  }

  func preloadResources() {
    ImageTransform.webservice.getResources { dump($0) }
  }

  // MARK: Generic displays Push & Present
  // ============================================================

  /// Show/Present Sticker Module with Navigation Controller
  /// - Parameters:
  ///   - fromRootViewController: Present from
  ///   - isModallyPresented: Present modally or not - Default value is false
  ///   - animated: Bool default is true
  ///   - isFullScreen: Optional - Default value is false
  ///   - withImagePicker: Optional - Default value is false
  ///   - inputImage: Optional - Default value is nil
  ///   - editModel: Optional - Default value is nil
  public func present(fromRootViewController: UIViewController, isModallyPresented: Bool = false, animated: Bool = true, isFullScreen: Bool = false, withImagePicker: Bool = false, inputImage: UIImage? = nil, editModel: StickerEditImageModel? = nil) {
    ImageTransform.shared.isAnimated = animated
    ImageTransform.shared.isModallyPresented = isModallyPresented
    ImageTransform.shared.isFullyPresented = isFullScreen
    ImageTransform.shared.isPresentedWithImagePicker = withImagePicker

    let controller = setupViewController(withImagePicker: withImagePicker, inputImage: inputImage, editModel: editModel)
    guard let controllerPresenting = controller else {
      return
    }
    presentViewController(
      fromRootViewController: fromRootViewController,
      controllerPresenting: controllerPresenting,
      isModallyPresented: isModallyPresented,
      animated: animated,
      isFullScreen: isFullScreen
    )
  }

  /// Push Stricker Module from your own Navigation Controller
  /// - Parameters:
  ///   - nav: Your navigation Controller
  ///   - animated: Bool default is true
  ///   - withImagePicker: Optional - Default value is false
  ///   - inputImage: Optional - Default value is nil
  ///   - editModel: Optional - Default value is nil
  public func push(fromNavigationController nav: UINavigationController, animated: Bool = true, withImagePicker: Bool = false, inputImage: UIImage? = nil, editModel: StickerEditImageModel? = nil) {
    ImageTransform.shared.isAnimated = animated
    ImageTransform.shared.isPresentedWithImagePicker = withImagePicker
    let controller = setupViewController(withImagePicker: withImagePicker, inputImage: inputImage, editModel: editModel)
    guard let controllerPresenting = controller else {
      return
    }
    isModulePushed = true
    currentPushedNavigationController = nav
    nav.pushViewController(controllerPresenting, animated: animated)
  }

  // MARK: Child View Controller life-cyle
  // ============================================================

  /// This method can be used to add Sticker Module with Navigation Controller in to your Tabbar or any other VC
  /// Better to use, for Tabbar add empty VC and than add asChild.
  /// - Parameter parent: Parent View Controller to add as child.
  ///  - withCloseShareButtons: Bool - Optinal default is false - For removing child from parent and visibility with share and download buttons
  ///   - withImagePicker: Optional - Default value is false
  ///   - inputImage: Optional - Default value is nil
  ///   - editModel: Optional - Default value is nil
  public func addChild(parent: UIViewController, withCloseShareButtons: Bool = true, withImagePicker: Bool = false, inputImage: UIImage? = nil, editModel: StickerEditImageModel? = nil) {
    ImageTransform.shared.withCloseShareButtons = withCloseShareButtons
    ImageTransform.shared.isPresentedWithImagePicker = withImagePicker
    let controller = setupViewController(withImagePicker: withImagePicker, inputImage: inputImage, editModel: editModel)
    guard let controllerPresenting = controller else {
      return
    }
    stickerNavigationViewController = UINavigationController(rootViewController: controllerPresenting)
    parent.addChild(stickerNavigationViewController!)
    parent.view.addSubview(stickerNavigationViewController!.view)
    stickerNavigationViewController!.didMove(toParent: parent)
  }

  /// This method can be used to add Sticker Module with Navigation Controller in to your Tabbar or any other VC
  /// Better to use, for Tabbar add empty VC and than add asChild to Container View
  /// - Parameters:
  ///  - parent: Parent View Controller to add as child.
  ///  - view: UIView which is container
  ///  - withCloseShareButtons: Bool - Optinal default is false - For removing child from parent and visibility with share and download buttons
  ///   - withImagePicker: Optional - Default value is false
  ///   - inputImage: Optional - Default value is nil
  ///   - editModel: Optional - Default value is nil
  public func addChildInView(parent: UIViewController, view: UIView, withCloseShareButtons: Bool = true, withImagePicker: Bool = false, inputImage: UIImage? = nil, editModel: StickerEditImageModel? = nil) {
    ImageTransform.shared.withCloseShareButtons = withCloseShareButtons
    ImageTransform.shared.isPresentedWithImagePicker = withImagePicker
    let controller = setupViewController(withImagePicker: withImagePicker, inputImage: inputImage, editModel: editModel)
    guard let controllerPresenting = controller else {
      return
    }
    stickerNavigationViewController = UINavigationController(rootViewController: controllerPresenting)
    parent.addChild(stickerNavigationViewController!)
    view.addSubview(stickerNavigationViewController!.view)
    stickerNavigationViewController!.didMove(toParent: parent)
  }

  /// Remove from Parent if it is already added as child VC
  public func removeChild() {
    if stickerNavigationViewController != nil {
      stickerNavigationViewController!.willMove(toParent: nil)
      stickerNavigationViewController!.removeFromParent()
      stickerNavigationViewController!.view.removeFromSuperview()
    }
  }

  public static func image(named: String) -> UIImage? {
    return UIImage.init(named: named, in: Bundle(for: ImageTransform.self), compatibleWith: nil)
  }

  @discardableResult
  public func addColorOptions(stickerColors: [String]) -> ImageTransform {
    if !stickerColors.isEmpty {
      let isColorSelectionFound = stickerColors.contains("ColorSelection")
      if isColorSelectionFound == false {
        ImageTransform.shared.stickerColors = stickerColors
        ImageTransform.shared.stickerColors.append("ColorSelection")
      }
    }

    return self
  }
}

// MARK: - callbacks
public extension ImageTransform {

  // public callbacks
  func onLoadFailed(loadFailed: @escaping DefaultListener) -> ImageTransform {
    onLoadFailed = loadFailed
    return self
  }

  func ondidViewOpened( didViewOpened: @escaping DefaultListener) -> ImageTransform {
    ondidViewOpened = didViewOpened
    return self
  }

  func ondidTapCloseButton(didTapCloseButton: @escaping DefaultListener) -> ImageTransform {
    onDidTapCloseButton = didTapCloseButton
    return self
  }

  func onEditFinishBlock(editFinished: @escaping EditFinishBlock) -> ImageTransform {
    onEditFinishBlock = editFinished
    return self
  }

  private func didEditFinished(image: UIImage, editModel: StickerEditImageModel) {
    onEditFinishBlock?(image, editModel)
  }

  // executation of callbacks
  private func didTapCloseButton() {
    onDidTapCloseButton?()
  }

  private func didViewOpened() {
    ondidViewOpened?()
  }

  private func loadFailed() {
    ondidViewOpened?()
  }

  func setupViewController(withImagePicker: Bool, inputImage: UIImage?, editModel: StickerEditImageModel?) -> UIViewController? {
    let controllerString = withImagePicker ? "ImagePickerViewController" : "ImageTransformViewController"
    let controller = storyboard.instantiateViewController(withIdentifier: controllerString)
    if !withImagePicker {
      guard let imageTransformVC = controller as? ImageTransformViewController  else { return nil }
      imageTransformVC.theImage = inputImage
      imageTransformVC.currentEditModel = editModel
      return imageTransformVC
    }
    return controller
  }

  func presentViewController(fromRootViewController: UIViewController, controllerPresenting: UIViewController, isModallyPresented: Bool, animated: Bool, isFullScreen: Bool) {
    if isModallyPresented {
      controllerPresenting.modalPresentationStyle = isFullScreen ? .fullScreen : .formSheet
      fromRootViewController.present(controllerPresenting, animated: animated, completion: didViewOpened)
    } else {
      stickerNavigationViewController = UINavigationController(rootViewController: controllerPresenting)
      stickerNavigationViewController!.modalPresentationStyle = isFullScreen ? .fullScreen : .formSheet
      fromRootViewController.present(stickerNavigationViewController!, animated: animated, completion: didViewOpened)
    }
  }
}

extension ImageTransform: WebServiceDelegate {
  func loadFailed(_ err: String) {
    loadFailed()
  }
}
