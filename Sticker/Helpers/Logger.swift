import Foundation

public protocol LogSender {
  func send(message: String)
  func send(error: Error)
}

class CrashlyticsLogSender: LogSender {
  func send(error: Error) {
//    FirebaseCrashlytics.Crashlytics.crashlytics().record(error: error)
  }

  func send(message: String) {
//    FirebaseCrashlytics.Crashlytics.crashlytics().log(message)
  }
}


public enum LoggerLogLevel: Int {
  case verbose = 6
  case warning = 4
  case error = 2
  case silent = 0
}

public struct LoggerConfig {
  public var logSender: LogSender?
  public var setNeedsToSend: Bool
  public var logLevel: LoggerLogLevel
}

public enum Logger {
  static var config = LoggerConfig(logSender: nil, setNeedsToSend: false, logLevel: .silent) {
    didSet {
      Logger.logSender = config.logSender
      Logger.setNeedsToSend = config.setNeedsToSend
      Logger.logLevel = config.logLevel
    }
  }

  public static var logSender: LogSender?
  public static var logLevel: LoggerLogLevel = .verbose
  public static var setNeedsToSend = false
  public static var mainEmoji = "🌄"
  public static var errorEmoji = "❌❌❌"
  public static var warningEmoji = "⚠️"
  public static var infoEmoji = "ℹ️"

  static func printer(_ message: String) {
    print("\(message)")
    self.send(message: message)
  }

  static func printer(_ error: Error) {
    print("\(self.mainEmoji) \(self.errorEmoji) \(error) - localizedDescription: \(error.localizedDescription)")
    self.send(error: error)
  }

  public static func log(_ message: String) {
    if self.logLevel.rawValue < LoggerLogLevel.verbose.rawValue { return }
    self.printer("\(self.mainEmoji) \(self.infoEmoji) \(message)")
  }

  public static func dump<T>(_ value: T, name: String? = nil, indent: Int = 0, maxDepth: Int = .max, maxItems: Int = .max) {
    if self.logLevel.rawValue < LoggerLogLevel.verbose.rawValue { return }
    Logger.log("Dumping Value of: \(T.self)")
    dump(T.self, name: name, indent: indent, maxDepth: maxDepth, maxItems: maxItems)
  }

  public static func error(_ error: Error) {
    if self.logLevel.rawValue < LoggerLogLevel.error.rawValue { return }
    self.printer(error)
  }

  public static func error(_ message: String) {
    if self.logLevel.rawValue < LoggerLogLevel.error.rawValue { return }
    self.printer("\(self.mainEmoji) \(self.errorEmoji) \(message)")
  }

  public static func warning(_ message: String) {
    if self.logLevel.rawValue < LoggerLogLevel.warning.rawValue { return }
    self.printer("\(self.mainEmoji) \(self.warningEmoji) \(message)")
  }

  public static func line() {
    if self.logLevel == .silent { return }
    self.printer("⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜")
  }

  static func send(message: String) {
    if self.setNeedsToSend {
      self.logSender?.send(message: message)
    }
  }

  static func send(error: Error) {
    if self.setNeedsToSend {
      self.logSender?.send(error: error)
    }
  }
}
