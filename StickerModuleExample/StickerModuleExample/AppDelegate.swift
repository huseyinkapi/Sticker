import UIKit
import Sticker

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
/*
    let fontName =  "Cera Pro Light Italic"
    let url = URL(string: "https://www.50dirham.com/v1/sticker_test?asd2=*")!
    let fontUrl = Bundle.main.url(forResource: fontName, withExtension: "otf")!
    ImageTransform.start(with: url, projectID: "5ed8f7b987fd340a1c0aee17").add(fontName: fontName, fontPathUrl: fontUrl).add(color: UIColor(red: 20, green: 20, blue: 20, alpha: 1))
     */
    
    /*
    let fontName =  "Cera Pro Light Italic"
    let url = URL(string: "https://www.50dirham.com/v1/sticker_module?asd2=*")!
    let fontUrl = Bundle.main.url(forResource: fontName, withExtension: "otf")!
    ImageTransform.start(with: url, projectID: "5ed8f7b987fd340a1c0aee17").add(fontName: fontName, fontPathUrl: fontUrl).add(color: UIColor(red: 20, green: 20, blue: 20, alpha: 1))
    
    */
    
    
    let url = URL(string: "https://www.50dirham.com/v1/tattoo_module?asd2=*")! // the api url needed for sticker thumbnails and sticker images
    ImageTransform.start(with: url, projectID: "5ff4ab033831fb0001a0dee6").addColorOptions(stickerColors: ["#FFFFFF", "#000000", "#C15B2E", "#2EC150", "#2E4AC1", "#C12E99"])  

    
    return true
  }


}

