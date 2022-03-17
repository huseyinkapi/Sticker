//
//  Configurations.swift
//  Sticker
//
//  Created by Huseyin Kapi on 12.01.2021.
//

import Foundation
import UIKit

public class Configurations {

  public static let shared = Configurations()

  var bgClr: UIColor!
  var secondaryClr: UIColor!
  var textClr: UIColor!
  var secondaryTextClr: UIColor!
  var takePhotoButtonTextClr: UIColor!
  var selectorsBackClr: UIColor!
  var navigationTitleClr: UIColor!

  var primaryTextFont: UIFont!
  var secondaryTextFont: UIFont!
  var titleFnt: UIFont!
  var titleText: String!
  var descriptionText: String!
  var navBarTitleText: String!

  var photoActionText: String!
  var takePhotoButtonText: String!

  var alertTitle: String!
  var alertMessageText: String!
  var alertButtonTitle: String!
  var alertSavingErrorText: String!

  var sourceSelectionTitle: String!
  var sourceSelectionMessage: String!
  var cameraSourceText: String!
  var photoGallerySourceText: String!
  var cancelText: String!

  var closeAlertTitleText: String!
  var closeAlertMessageText: String!
  var closeAlertOkButtonText: String!
  var closeAlertCancelButtonText: String!

  /// Configure Title Texts in app
  /// - Parameters:
  ///   - title: Title of the first ImagePickerViewController | This is not Navigation Controller's title!
  ///   - descriptionText: Description of the first ImagePickerViewController
  ///   - navTitle: Title of the first NavBar | Default is Your Next Tattoo
  public func configureTitleTexts(withTitle title: String? = "Your Next Tattoo", withDescriptionText description: String? = " ", withNavBarTitle navTitle: String? = " ") {
    titleText = title
    descriptionText = description
    navBarTitleText = navTitle
  }

  /// Configure Action Texts in app
  /// - Parameters:
  ///   - photoActionText: Action text of the putting a nice shot of the first ImagePickerViewController
  ///   - takePhotoButtonText: Action text of the take photo button of the first ImagePickerViewController of the first ImagePickerViewController
  public func configureActionTexts(withPhotoActionText photoActionString: String? = "Let's put a nice shot here first", withTakePhotoButtonText takePhotoButtonString: String? = "Take a photo and continue") {
    photoActionText = photoActionString
    takePhotoButtonText = takePhotoButtonString
  }

  /// Configure Alert Texts in app
  /// - Parameters:
  ///   - alertTitle =  Title of the alert showing when saving image to album
  ///   - alertMessageText = Message of  the alert showing when saving image to album
  ///   - alertButtonTitle = Button title of  the alert showing when saving image to album
  ///   - alertSavingErrorText = Saving error text  of the alert showing when saving image to album is not succesful
  public func configurePhotoSavedAlertTexts(withAlertTitle alertTitleString: String? = "Saved!", withAlertMessageText alertMessageString: String? = "Your altered image has been saved to your photos.", withAlertButtonTitle alertButtonTitleString: String? = "OK", withAlertSavingErrorText alertSavingErrorString: String? = "Save error") {
    alertTitle = alertTitleString
    alertMessageText = alertMessageString
    alertButtonTitle = alertButtonTitleString
    alertSavingErrorText = alertSavingErrorString
  }

  /// Configure Source Selection ActionSheet Texts in app
  /// - Parameters:
  ///   - sourceSelectionTitle =  Title of the source selection actionsheet in the first image picker screen
  ///   -  sourceSelectionMessage =  Message of the source selection actionsheet in the first image picker screen
  ///   -  cameraSourceText =  Camera source text of the source selection actionsheet in the first image picker screen
  ///   -  photoGallerySourceText =  Photo gallery source text of the source selection actionsheet in the first image picker screen
  ///   -  cancelText =  Cancel text of the source selection actionsheet in the first image picker screen
  public func configureSelectionOfImageSourceText(withSourceSelectionTitle sourceSelectionTitleString: String? = "Image Selection", withSourceSelectionMessage sourceSelectionMessageString: String? = "From where you want to pick this image?", withCameraSourceText cameraSourceString: String? = "Camera", withPhotoGallerySourceText photoGallerySourceString: String? = "Photo Album", withCancelText cancelString: String? = "Cancel") {
    sourceSelectionTitle = sourceSelectionTitleString
    sourceSelectionMessage = sourceSelectionMessageString
    cameraSourceText = cameraSourceString
    photoGallerySourceText = photoGallerySourceString
    cancelText = cancelString
  }

  /// Configure Source Selection ActionSheet Texts in app
  /// - Parameters:
  ///   - alertTitleString =  Title of the close alert
  ///   -  alertMessageString =  Message text of the close alert
  ///   -  alertOkButtonTextString =  OK of the close alert
  ///   -  alertCancelButtonTextString =  Cancel of the close alert
  public func configureCloseAlertTexts(withAlertTitle alertTitleString: String? = "Changes will not be saved on the application but you can always download the picture to your device with the button on the top right corner. Are you sure you want to exit now?", withAlertMessageText alertMessageString: String? = "", withAlertOkButtonText alertOkButtonTextString: String? = "OK", withAlertCancelButtonText alertCancelButtonTextString: String? = "Cancel") {

    closeAlertTitleText = alertTitleString
    closeAlertMessageText = alertMessageString
    closeAlertOkButtonText = alertOkButtonTextString
    closeAlertCancelButtonText = alertCancelButtonTextString
  }


  /// # Configure Sticker Colors
  /// - Parameters:
  ///   - bgColor: Backgrounds (Navigationbar, CatergoryCollectionCell, category selected item text color)
  ///   - secondaryColor: Backgrounds (ThumbNail ColectionView, ImageView and scrollView in ImageTransform)
  ///   - textColor: All main texts in ImagePickerViewController(first screen), Title and explanation
  ///   - secondaryTextColor: The description text  in ImagePickerViewController(first screen)
  ///   - TakePhotoButtonTextColor: Color of Take Photo button in ImagePickerViewController(first screen)
  ///   - SelectorsBackColor: Background Color of Category and Thumbnail  collection views in  ImageTransformViewController(second screen)
  ///   - NavigationTitleColor: Text color of nagivation title
  public func configureColors(bgColor: UIColor? = .defaultBgColor, secondaryColor: UIColor? = .defaultSecondaryColor, textColor: UIColor? = .defaultTextColor, secondaryTextColor: UIColor? = .defaultSecondaryColor, takePhotoButtonTextColor: UIColor? = .white, selectorsBackColor: UIColor? = .white, navigationTitleColor: UIColor? = .white) {

    bgClr = bgColor
    secondaryClr = secondaryColor
    textClr = textColor
    secondaryTextClr = secondaryTextColor
    takePhotoButtonTextClr = takePhotoButtonTextColor
    selectorsBackClr = selectorsBackColor
    navigationTitleClr = navigationTitleColor
  }

  /// # Configure Sticker Fonts
  /// ## If not called at all it will get default values which is HelveticaNeue
  /// - Parameters:
  ///   - primaryFont: Cell main text label, default value is -- `UIFont.boldSystemFont(ofSize: 21)`
  ///   - secondaryFont: Cell detail text label, description labels, default value is `UIFont.systemFont(ofSize: 20)`
  ///   - titleFont: Navigation Bar Title, Course title, default value is `UIFont.systemFont(ofSize: 27)`
  public func configureFonts(primaryFont: UIFont? = .boldSystemFont(ofSize: 21), secondaryFont: UIFont? = .systemFont(ofSize: 20), titleFont: UIFont? = .boldSystemFont(ofSize: 27)) {
    primaryTextFont = primaryFont
    secondaryTextFont = secondaryFont
    titleFnt = titleFont
  }
}
