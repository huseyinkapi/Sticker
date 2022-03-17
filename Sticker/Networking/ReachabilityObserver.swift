import Foundation

// Reachability
// declare this property where it won't go out of scope relative to your listener
private var reachability: Reachability!

protocol ReachabilityAction {
  func reachabilityChanged(_ isReachable: Bool)
}

protocol ReachabilityObserver: AnyObject, ReachabilityAction {
  func addReachabilityObserver() throws
  func removeReachabilityObserver()
}

// Declaring default implementation of adding/removing observer
extension ReachabilityObserver {
  /** Subscribe on reachability changing */
  func addReachabilityObserver() throws {
    reachability = try Reachability()

    reachability.whenReachable = { [weak self] _ in
      self?.reachabilityChanged(true)
    }

    reachability.whenUnreachable = { [weak self] _ in
      self?.reachabilityChanged(false)
    }

    try reachability.startNotifier()
  }

  /** Unsubscribe */
  func removeReachabilityObserver() {
    reachability.stopNotifier()
    reachability = nil
  }
}
