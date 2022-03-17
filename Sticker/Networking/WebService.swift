import Foundation

struct Constants {
  static let cacheTimeout = TimeInterval(60 * 60) // 1 hour
  static let loadingTimeut = 7.0
  static let maxTrialCount = 3
  static let waitTimeSeconds = 0.5
  static let platformType = "IOS"
  static let unknownRegionCode = "ZZ"
}

public enum DirhamApiError: Error {
  case unableToParseURL
  case unableToConnectApi(errorMessage: String)
  case requestCreateError
  case unableToParseData
  case selfReferenceError
  case networkUnavalaible
  case responseError(error: Error)
  case maxTrialReeached
}

public enum WebServiceResult {
  case success(_ stickers: Stickers)
  case failure(_ error: DirhamApiError)
}

class Webservice {

  typealias Result = (WebServiceResult) -> Void
  private let url: URL
  private let projectID: String
  private let downloadTime: Date
  private var loadingTimer: Timer?
  private var maxLoadingTimeout = 5
  private var isLoadingFinished = false

  weak var delegate: WebServiceDelegate?


  init(url: URL, projectID: String, delegate: WebServiceDelegate) {
    self.url = url
    self.projectID = projectID
    self.delegate = delegate
    downloadTime = UserDefaultsConfig.latestFetchDate
  }

  private func parse(data: Data) -> Stickers {
    JsonCacheManager.shared.saveFile(data: data)

    let obj = try! JSONDecoder().decode(Stickers.self, from: data)
    return obj
  }

  private func getRequest() -> URLRequest {
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = ["projectId": projectID]
    request.httpMethod = "GET"
    return request
  }

  private func load(completion: @escaping Result) {
    URLSession.shared.dataTask(with: getRequest()) { data, _, error in
      if let error = error {
        completion(.failure(.responseError(error: error)))
      }
      if let result = data.flatMap(self.parse(data:)) {
        UserDefaultsConfig.latestFetchDate = Date()
        completion(.success(result))
      } else {
        Logger.error("response data is nil")
      }
    }
    .resume()
  }

  private func loadWithTrial(
    _ trialCount: Int = 1,
    completionHandler: @escaping Result
  ) {
    load { result in
      switch result {
      case .failure(let error):
        Logger.error(error)
        if trialCount <= Constants.maxTrialCount {
          Logger.log("\(trialCount). trial for resource request")
          DispatchQueue.main.asyncAfter(deadline: .now() + Constants.waitTimeSeconds, execute: {
            self.loadWithTrial(trialCount + 1, completionHandler: completionHandler)
          })
        } else {
          Logger.log("Request failure although tried \(Constants.maxTrialCount) times")
          completionHandler(.failure(.maxTrialReeached))
        }
      case .success(let stickers):
        completionHandler(.success(stickers))
      }
    }
  }

  private func startLoadingTimeout() {
    loadingTimer = Timer.scheduledTimer(
      timeInterval: TimeInterval(maxLoadingTimeout),
      target: self,
      selector: #selector(loadingTimeoutReached),
      userInfo: nil,
      repeats: false)
  }

  @objc private func loadingTimeoutReached () {
    let error = "Timeout reached for loading placement : \(maxLoadingTimeout)"
    Logger.error(error)

    if !isLoadingFinished {
      self.delegate?.loadFailed(error)
    }
    isLoadingFinished = true
    self.clearAllTimers()
  }

  private func clearAllTimers() {
    self.loadingTimer?.invalidate()
  }

  public func getResources(completion: @escaping Result) {
    let reachability = try! Reachability()
    switch reachability.connection {
    case .unavailable:
      completion(.failure(.networkUnavalaible))
      return
    default: break
    }

    if !shouldMakeNewRequest(), JsonCacheManager.shared.doesFileExist {
      if let data = try? JsonCacheManager.shared.getData().get(),
      let stickers = try? Stickers(data: data) {
        completion(.success(stickers))
        isLoadingFinished = true
      }
      return
    }

    loadWithTrial(completionHandler: completion)
  }

  func shouldMakeNewRequest() -> Bool {
    let differenceInSeconds = Date().timeIntervalSince(downloadTime)
    Logger.log("resources downlaod time has passed \(differenceInSeconds) seconds")

    if differenceInSeconds > Constants.cacheTimeout {
      Logger.log("resource downlaod time is old, so get config again")
      return true
    } else {
      return false
    }
  }
}

protocol WebServiceDelegate: AnyObject {
  func loadFailed(_ err: String)
}
