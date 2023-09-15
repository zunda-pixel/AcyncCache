import Foundation

public enum DataStoreKey: Hashable {
  case request(URLRequest)
  case string(String)
}
