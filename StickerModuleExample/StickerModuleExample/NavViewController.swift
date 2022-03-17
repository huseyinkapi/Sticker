//
//  NavViewController.swift
//  StickerModuleExample
//
//  Created by Huseyin Kapi on 12.01.2021.
//

import UIKit
import Sticker

class NavViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Configure Stickers' Fonts & Colors - Optional
    // ============================================================
  ImageTransform.configure.configureColors(bgColor: UIColor.blue, secondaryColor: UIColor.red, textColor: UIColor.yellow, secondaryTextColor: UIColor.green, takePhotoButtonTextColor: UIColor.gray, selectorsBackColor: UIColor.purple, navigationTitleColor: UIColor.orange)
  ImageTransform.configure.configureFonts(primaryFont: .boldSystemFont(ofSize: 21), secondaryFont: .systemFont(ofSize: 20), titleFont: .boldSystemFont(ofSize: 27))
  ImageTransform.configure.configureTitleTexts(withTitle: "Your Next Tattoo", withDescriptionText: "Lorem Ipsum is simply dummy text of the printing and typesetting...", withNavBarTitle: "TopBar")
  ImageTransform.configure.configureActionTexts(withPhotoActionText: "Let’s put a nice shot here first", withTakePhotoButtonText: "Take a photo and continue")
  ImageTransform.configure.configurePhotoSavedAlertTexts(withAlertTitle: "Saved!", withAlertMessageText: "Your altered image has been saved to your photos.", withAlertButtonTitle: "OK", withAlertSavingErrorText: "Save Error")
  ImageTransform.configure.configureSelectionOfImageSourceText(withSourceSelectionTitle: "Image Selection", withSourceSelectionMessage: "From where you want to pick this image?", withCameraSourceText: "Camera", withPhotoGallerySourceText: "Photo Album", withCancelText: "Cancel")
  }

  @IBAction func buttonTap(_ sender: Any) {

    /*
    ImageTransform.shared.ondidViewOpened {
        print("ondidViewOpened")
    }.onLoadFailed {
        print("onLoadFailed")
    }.onEditFinishBlock(editFinished: { (editedImage, stickerEditModel) in
        print("onEditFinishBlock")
    }).push(
      fromNavigationController: <#T##UINavigationController#>,
      animated: <#T##Bool#>,
      withImagePicker: <#T##Bool#>,
      inputImage: <#T##UIImage?#>,
      editModel: <#T##StickerEditImageModel?#>)
    */



    ImageTransform.shared.ondidViewOpened {
        print("ondidViewOpened")
    }.onLoadFailed {
        print("onLoadFailed")
    }.onEditFinishBlock(editFinished: { (editedImage, stickerEditModel) in
        print("onEditFinishBlock")
    }).addChildInView(parent: self, view: self.view, withCloseShareButtons: true, withImagePicker: false, inputImage: nil, editModel: nil)



  }
}
