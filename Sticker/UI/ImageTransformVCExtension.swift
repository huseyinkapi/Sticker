//
//  CollectionViewCells.swift
//  Sticker
//
//  Created by Huseyin Kapi on 12.01.2021.
//

import Foundation
import UIKit
import FlexColorPicker

extension ImageTransformViewController {

  func setupUI() {
    self.scrollView.minimumZoomScale = 1
    self.scrollView.maximumZoomScale = 3
    self.scrollView.delegate = self

    self.containerView = UIView()
    self.containerView.clipsToBounds = true
    self.scrollView.addSubview(self.containerView)

    self.imageView = UIImageView(image: self.originalImage)
    self.imageView.contentMode = .scaleAspectFit
    self.imageView.clipsToBounds = true
    self.containerView.addSubview(self.imageView)

    self.stickersContainer = UIView()
    self.containerView.addSubview(self.stickersContainer)

    self.stickers.forEach { view in
      self.stickersContainer.addSubview(view)
      if let ivv = view as? ImageStickerView {
        ivv.frame = ivv.originFrame
        self.configImageSticker(ivv)
      }
    }
    arrangeActivityController()
    arrangeCategoryCell()
    arrangeThumbnailCell()
    arrangeColorCell()
    self.rotationImageView()
  }

  func configureNavigationBar() {

    if ImageTransform.shared.withCloseShareButtons {
      self.title = ImageTransform.configure.navBarTitleText
      let image = UIImage(named: "ic_back", in: ImageTransform.bundle, compatibleWith: nil)
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(
        image: image,
        style: .plain,
        target: self,
        action: #selector(closeButtonAction)
      )
      let imageShare = UIImage(named: "ic_share", in: ImageTransform.bundle, compatibleWith: nil)
      let imageDownload = UIImage(named: "ic_download", in: ImageTransform.bundle, compatibleWith: nil)
      let barItemShare = UIBarButtonItem(
        image: imageShare,
        style: .plain,
        target: self,
        action: #selector(shareButtonAction)
      )
      let barItemDownload = UIBarButtonItem(
        image: imageDownload,
        style: .plain,
        target: self,
        action: #selector(downloadButtonAction)
      )
      self.navigationItem.rightBarButtonItems = [barItemDownload, barItemShare]
    }

    navigationController?.navigationBar.tintColor = ImageTransform.configure.navigationTitleClr
    navigationController?.navigationBar.barTintColor = ImageTransform.configure.bgClr
    navigationController?.navigationBar.titleTextAttributes = [
      .foregroundColor: ImageTransform.configure.navigationTitleClr!,
      .font: ImageTransform.configure.titleFnt.withSize(21)
    ]
    navigationItem.backButtonTitle = ""
  }

  func configureColors() {
    view.backgroundColor = ImageTransform.configure.secondaryClr
    scrollView.backgroundColor = ImageTransform.configure.secondaryClr
    self.imageView.backgroundColor = ImageTransform.configure.secondaryClr
    thumbnailCollectionView.backgroundColor = ImageTransform.configure.secondaryClr
    categoryCollectionView.backgroundColor = ImageTransform.configure.bgClr
  }

  func firstSetAndCheck() {
    theImage = theImage ?? UIImage.init(named: "placeholderSticker.png")
    self.originalImage = theImage
    self.editImage = theImage
    self.editRect = CGRect(origin: .zero, size: theImage!.size)
    self.angle = 0
    var imStic: [(state: StickerImageState, index: Int)] = []
    if currentEditModel != nil {
      self.editRect = currentEditModel?.editRect ?? CGRect(origin: .zero, size: theImage!.size)
      self.angle = currentEditModel?.angle ?? 0
      imStic = currentEditModel?.stickerImages ?? []
    }
    var stickers: [UIView?] = Array(repeating: nil, count: imStic.count)
    imStic.forEach { cache in
      let vvv = ImageStickerView(from: cache.state)
      stickers[cache.index] = vvv
    }
    self.stickers = stickers.compactMap { $0 }
  }

  func arrangeCategoryCell() {
    categoryCollectionView.dataSource = self
    categoryCollectionView.delegate = self
    categoryLayout = (categoryCollectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
    categoryLayout.itemSize = CGSize(
      width: view.bounds.width * 0.35,
      height: view.bounds.height
    )
    categoryCollectionView.collectionViewLayout = categoryLayout
    categoryCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    categoryCollectionView.showsVerticalScrollIndicator = false
    categoryCollectionView.showsHorizontalScrollIndicator = false

    categoryCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
  }

  func arrangeThumbnailCell() {
    thumbnailCollectionView.dataSource = self
    thumbnailCollectionView.delegate = self
    (thumbnailCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = .zero
    thumbnailCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
  }

  func arrangeColorCell() {
    colorCollectionView.dataSource = self
    colorCollectionView.delegate = self
    (colorCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = .zero
    colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
    colorCollectionView.isHidden = true
  }

  func arrangeActivityController() {
    view.addSubview(activityControl)
    NSLayoutConstraint.activate([
      activityControl.widthAnchor.constraint(equalTo: view.widthAnchor),
      activityControl.heightAnchor.constraint(equalTo: view.heightAnchor),
      activityControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityControl.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    activityControl.startAnimating()
  }
}

class ColorCell: UICollectionViewCell {
  @IBOutlet var cellBackgroundImageView: UIImageView!
  @IBOutlet var cellImageView: UIImageView!

  func setupCell(with hex: String) {
    if hex == "ColorSelection" {
      cellImageView.backgroundColor = UIColor.clear
      cellBackgroundImageView.image = UIImage.init(named: "colorSelector.png")
    } else {
      cellImageView.backgroundColor = UIColor(hexString: hex)
    }

    cellImageView.layer.masksToBounds = true
    cellImageView.layer.cornerRadius = cellImageView.bounds.height / 2

    cellBackgroundImageView.layer.masksToBounds = true
    cellBackgroundImageView.layer.cornerRadius = cellBackgroundImageView.bounds.height / 2
  }
}

class CategoryCell: UICollectionViewCell {
  @IBOutlet var cellLabel: UILabel!

  func setupCell(categoryName: String, indexPathItem: Int, currentCategoryIndex: Int) {
    self.cellLabel.text = categoryName

    if indexPathItem == currentCategoryIndex {
      self.cellLabel.backgroundColor = ImageTransform.configure.selectorsBackClr
      self.cellLabel.layer.masksToBounds = true
      self.cellLabel.layer.cornerRadius = 15.0
      self.cellLabel.textColor = ImageTransform.configure.bgClr
      self.cellLabel.font = ImageTransform.configure.primaryTextFont.withSize(17)
      self.cellLabel.adjustsFontForContentSizeCategory = true
    } else {
      self.cellLabel.backgroundColor = UIColor.clear
      self.cellLabel.layer.masksToBounds = true
      self.cellLabel.layer.cornerRadius = 0.0
      self.cellLabel.textColor = UIColor.white
      self.cellLabel.font = ImageTransform.configure.secondaryTextFont.withSize(17)
      self.cellLabel.adjustsFontForContentSizeCategory = true
    }
  }
}

class ThumbnailCell: UICollectionViewCell {
  @IBOutlet var thumbnailImage: UIImageView!

  func setupCell(with sticker: Sticker, indexPathItem: Int, currentStickerThumbnailIndex: Int) {
    if indexPathItem == currentStickerThumbnailIndex {
      thumbnailImage.backgroundColor = ImageTransform.configure.selectorsBackClr
    } else {
      thumbnailImage.backgroundColor = UIColor.clear
    }
    guard let url = URL(string: sticker.stickerThumbnailURL.encodedURLString()) else { return }
    thumbnailImage.kf.setImage(with: url)
  }
}

enum CellType: String {
  case colorCell = "ColorCell"
  case categoryCell = "CategoryCell"
  case thumbnailCell = "ThumbnailCell"

  var id: String {
    rawValue
  }
}

// MARK: scroll view delegate
extension ImageTransformViewController: UIScrollViewDelegate {

  public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.containerView
  }

  public func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let offsetX = (scrollView.frame.width > scrollView.contentSize.width)
      ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
    let offsetY = (scrollView.frame.height > scrollView.contentSize.height)
      ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
    self.containerView.center = CGPoint(
      x: scrollView.contentSize.width * 0.5 + offsetX,
      y: scrollView.contentSize.height * 0.5 + offsetY
    )
  }
}

// MARK: - layout size for Thumbnail images and category collection view

extension ImageTransformViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == thumbnailCollectionView {
      return CGSize(width: collectionView.frame.width * 0.3, height: collectionView.frame.height * 0.8 )
    } else if collectionView == categoryCollectionView {
      return CGSize(width: collectionView.bounds.width * 0.35, height: collectionView.bounds.height * 0.9 )
    } /*else if collectionView == colorCollectionView {
      return CGSize(width: collectionView.bounds.width * 0.120, height: collectionView.bounds.height * 1.0 )
    }*/else if collectionView == colorCollectionView {
        return CGSize(width: 50.5, height: collectionView.bounds.height * 1.0 )
      } else {
      return CGSize.zero
    }
  }
}

extension ImageTransformViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == categoryCollectionView {
      return categoryData.count
    } else if collectionView == thumbnailCollectionView {
      return categoryData[safeIndex: currentCategoryIndex]?.stickers.count ?? 0
    } else if collectionView == colorCollectionView {
      return ImageTransform.shared.stickerColors.count
    }
    return 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == categoryCollectionView {
      let cell = collectionView.dequeue(type: CategoryCell.self, cellType: .categoryCell, indexPath: indexPath)
      if let category = categoryData[safeIndex: indexPath.item] {
        cell.setupCell(
          categoryName: category.localizedName,
          indexPathItem: indexPath.item,
          currentCategoryIndex: currentCategoryIndex
        )
      }
      return cell
    } else if collectionView == thumbnailCollectionView {
      let cell = collectionView.dequeue(type: ThumbnailCell.self, cellType: .thumbnailCell, indexPath: indexPath)
      if let category = categoryData[safeIndex: currentCategoryIndex] {
        cell.setupCell(
          with: category.stickers[indexPath.item],
          indexPathItem: indexPath.item,
          currentStickerThumbnailIndex: currentStickerThumbnailIndex
        )
      }
      return cell
    } else if collectionView == colorCollectionView {
      let cell = collectionView.dequeue(type: ColorCell.self, cellType: .colorCell, indexPath: indexPath)
      if let colorHexString = ImageTransform.shared.stickerColors[safeIndex: indexPath.item] {
        cell.setupCell(with: colorHexString)
      }
      return cell
    }
    return collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
  }

  // MARK: - scrollview
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if scrollView == categoryCollectionView {
      if !decelerate {
        userDidChangeCategory()
      }
    }
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView == categoryCollectionView {
      userDidChangeCategory()
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    if collectionView == categoryCollectionView {
      // check if the currentCenteredPage is not the page that was touched
      let currentCenteredPage = categoryLayout.currentCenteredPage
      if currentCenteredPage != indexPath.row {
        // trigger a scrollToPage(index: animated:)
        scrollCategory(index: indexPath.item)
        currentCategoryIndex = indexPath.item
      }
    } else if collectionView == thumbnailCollectionView {
      colorCollectionView.isHidden = true
      if let category = categoryData[safeIndex: currentCategoryIndex] {
        guard let url = URL(string: category.stickers[indexPath.item].stickerURL.encodedURLString()) else { return }
        self.addImageStickerView(url)

        let isColorChangable = category.stickers[indexPath.item].isColorChangable

        if isColorChangable {
          colorCollectionView.isHidden = false
          colorCollectionView.reloadData()
          colorCollectionView.layoutSubviews()
        }

        currentStickerThumbnailIndex = indexPath.item
      }
    } else if collectionView == colorCollectionView {
      if let colorHexString = ImageTransform.shared.stickerColors[safeIndex: indexPath.item] {
        if colorHexString == "ColorSelection" {
          colorPickerController = DefaultColorPickerViewController()
          colorPickerController!.delegate = self
          navigationController?.pushViewController(colorPickerController!, animated: true)
          // present(navigationController, animated: true, completion: nil)
        } else {
          self.changeColor(with: colorHexString)
        }
      }
    }
  }
}

extension ImageTransformViewController: StickerViewDelegate {

  func stickerBeginOperation(_ sticker: UIView) {
    print("stickerBeginOperation")
  }

  func stickerOnOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer) {
    print("stickerOnOperation")
  }

  func stickerEndOperation(_ sticker: UIView, panGes: UIPanGestureRecognizer) {
    print("stickerEndOperation")
  }

  func stickerDidTap(_ sticker: UIView) {
    print("stickerDidTap")
    self.lastEditedSticker = sticker as? ImageStickerView
  }
}
