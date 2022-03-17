import Foundation

@propertyWrapper
struct UserDefaultForConfig<T> {
  let key: String
  let defaultValue: T

  init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }

  var wrappedValue: T {
    get {
      if let value = UserDefaults.standard.object(forKey: key) as? T {
        return value
      }
      UserDefaults.standard.set(defaultValue, forKey: key)
      return defaultValue
    }
    set {
      UserDefaults.standard.set(newValue, forKey: key)
    }
  }
}

enum UserDefaultsConfig {
  @UserDefaultForConfig("resources_download_time", defaultValue: Date())
  static var latestFetchDate: Date
    
  @UserDefaultForConfig("closeAlertShown", defaultValue: false)
  static var closeAlertShown: Bool
}
