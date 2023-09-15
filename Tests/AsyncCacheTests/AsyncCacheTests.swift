import XCTest
import Cache
@testable import AsyncCache

final class AsyncCacheTests: XCTestCase {
  func testExample() throws {
    // XCTest Documentation
    // https://developer.apple.com/documentation/xctest
    
    // Defining Test Cases and Test Methods
    // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
  }
  
  let sampleURL = URL(string: "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png")!
  var request: URLRequest { URLRequest(url: sampleURL) }
  
  func testStoreData() async throws {
    let (data, _) = try await URLSession.shared.data(for: request)
    try await DataProvider.test.setData(data: data, key: .request(request), expiry: .never)
  }
  
  func testFetchData() async throws {
    _ = try await DataProvider.test.data(request: request, expiry: .never)
  }
  
  func testStoreAndRestoreData() async throws {
    let (data1, _) = try await URLSession.shared.data(for: request)
    try await DataProvider.test.setData(data: data1, key: .request(request), expiry: .never)
    let data2 = try await DataProvider.test.data(request: request, expiry: .never)
    XCTAssertEqual(data1, data2)
  }
  
  func testExpireData() async throws {
    let (data1, _) = try await URLSession.shared.data(for: request)
    try await DataProvider.test.setData(data: data1, key: .request(request), expiry: .seconds(1))
    try await Task.sleep(for: .seconds(2))
    let cachedData = await DataProvider.test.cachedData(request: request)
    XCTAssertNil(cachedData)
  }
}

extension DataProvider {
  static let test: DataProvider = .init(storage: .test)
}

extension Storage<DataStoreKey, Data> {
  static let test: Storage<DataStoreKey, Data> = try! .init(diskConfig: .test, memoryConfig: .test, transformer: .test)
}

extension DiskConfig {
  static let test: DiskConfig = .init(name: "Test")
}

extension MemoryConfig {
  static let test: MemoryConfig = .init()
}

extension Transformer<Data> {
  static let test: Transformer<Data> = .init(toData: { $0 }, fromData: { $0 })
}
