import UIKit

class ImagePickerViewController: UIViewController {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var letsPutLabel: UILabel!
  @IBOutlet weak var takePhotoBtn: UIButton!
  @IBOutlet weak var letsPutBtn: UIButton!
  @IBOutlet weak var modallyCloseBtn: UIButton!

  @IBAction func modallyCloseBtn(_ sender: Any) {
    self.dismiss(animated: ImageTransform.shared.isAnimated, completion: ImageTransform.shared.onDidTapCloseButton)
  }

  @IBAction func letsPutBtnDidTap(_ sender: Any) {
    self.showAlert(fromButton: letsPutBtn)
  }

  @IBAction func takePhotoBtnDidTap(_ sender: Any) {
    self.showAlert(fromButton: takePhotoBtn)
  }

  @objc func closeButtonAction() {
    if ImageTransform.shared.isModulePushed {
      self.navigationController?.popViewControllerWithHandler(
        isAnimated: ImageTransform.shared.isAnimated,
        completion: ImageTransform.shared.onDidTapCloseButton!
      )
    } else {
      self.dismiss(animated: ImageTransform.shared.isAnimated, completion: ImageTransform.shared.onDidTapCloseButton)
      ImageTransform.shared.removeChild()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    modallyCloseBtn.isHidden = ImageTransform.shared.isModallyPresented ? false : true

    configureNavigationBar()
    configureText()
    configureFonts()
    configureColors()
    takePhotoBtn.layer.masksToBounds = true
    takePhotoBtn.layer.cornerRadius = 20.0
  }

  func configureNavigationBar() {

    if ImageTransform.shared.withCloseShareButtons {
      let image = UIImage(named: "ic_back", in: ImageTransform.bundle, compatibleWith: nil)
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(
        image: image,
        style: .plain,
        target: self,
        action: #selector(closeButtonAction)
      )
      self.title = ImageTransform.configure.navBarTitleText
    }

    // navigationController?.navigationBar.tintColor = UIColor(red: 0.99, green: 0.26, blue: 0.51, alpha: 1.00)
    navigationController?.navigationBar.tintColor = ImageTransform.configure.navigationTitleClr
    navigationController?.navigationBar.barTintColor = ImageTransform.configure.bgClr
    navigationController?.navigationBar.titleTextAttributes = [
      .foregroundColor: ImageTransform.configure.navigationTitleClr!,
      .font: ImageTransform.configure.titleFnt.withSize(21)
    ]
    navigationItem.backButtonTitle = ""
  }

  func configureText() {
    titleLabel.text = ImageTransform.configure.titleText
    descriptionLabel.text = ImageTransform.configure.descriptionText
    letsPutLabel.text = ImageTransform.configure.photoActionText
    takePhotoBtn.setTitle(ImageTransform.configure.takePhotoButtonText, for: .normal)
  }

  func configureFonts() {
    titleLabel.font = ImageTransform.configure.titleFnt.withSize(27)
    descriptionLabel.font = ImageTransform.configure.secondaryTextFont.withSize(20)
    letsPutLabel.font = ImageTransform.configure.primaryTextFont.withSize(21)
    takePhotoBtn.titleLabel?.font = ImageTransform.configure.primaryTextFont.withSize(21)
  }

  func configureColors() {
    titleLabel.textColor = ImageTransform.configure.textClr
    descriptionLabel.textColor = ImageTransform.configure.secondaryTextClr
    letsPutLabel.textColor = ImageTransform.configure.textClr
    takePhotoBtn.setTitleColor(ImageTransform.configure.takePhotoButtonTextClr, for: .normal)
    takePhotoBtn.backgroundColor = ImageTransform.configure.textClr
  }
}

// MARK: - Image Picker
extension ImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  // Show alert to selected the media source type.
  private func showAlert(fromButton: UIButton) {
    let alert = UIAlertController(
      title: ImageTransform.configure.sourceSelectionTitle,
      message: ImageTransform.configure.sourceSelectionMessage,
      preferredStyle: .actionSheet
    )
    let action = UIAlertAction(title: ImageTransform.configure.cameraSourceText, style: .default, handler: { action in
      print(action)
      self.getImage(fromSourceType: .camera)
    })
    alert.addAction(action)
    alert.addAction(
       UIAlertAction(
         title: ImageTransform.configure.photoGallerySourceText,
         style: .default,
         handler: { _ in
           self.getImage(fromSourceType: .photoLibrary)
         }
       )
    )
    alert.addAction(UIAlertAction(title: ImageTransform.configure.cancelText, style: .destructive, handler: nil))
    alert.popoverPresentationController?.sourceView = fromButton
    self.present(alert, animated: true, completion: nil)
  }

  // get image from source type
  private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {

    // Check is source type available
    if UIImagePickerController.isSourceTypeAvailable(sourceType) {
      let imagePickerController = UIImagePickerController()
      imagePickerController.delegate = self
      imagePickerController.sourceType = sourceType
      self.present(imagePickerController, animated: true, completion: nil)
    }
  }

  // MARK: - UIImagePickerViewDelegate.
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

    self.dismiss(animated: true) { [weak self] in
      guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
      if ImageTransform.shared.isModulePushed {
        ImageTransform.shared
          .ondidViewOpened {
            print("View Opened")
          }
          .onLoadFailed(loadFailed: {
            print("Load Failed")
          })
          .push(fromNavigationController: ImageTransform.shared.currentPushedNavigationController!)
      } else {
        ImageTransform.shared
          .ondidViewOpened {
            print("View Opened")
          }
          .onLoadFailed(loadFailed: {
            print("Load Failed")
          })
          .present(
            fromRootViewController: self!,
            isModallyPresented: ImageTransform.shared.isModallyPresented,
            animated: ImageTransform.shared.isAnimated,
            isFullScreen: ImageTransform.shared.isFullyPresented,
            withImagePicker: false,
            inputImage: image,
            editModel: nil
          )
      }

      // self?.profileImgView.image = image
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}
