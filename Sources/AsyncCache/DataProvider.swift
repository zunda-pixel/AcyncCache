import Foundation
import Cache

public actor DataProvider {
  public let storage: Storage<DataStoreKey, Data>
  public var tasks: [DataStoreKey: Task<Data, any Error>] = [:]
  
  public init(storage: Storage<DataStoreKey, Data>) {
    self.storage = storage
  }
}

// SET
extension DataProvider {
  public func setData(data: Data, key: DataStoreKey, expiry: Expiry) throws {
    try storage.setObject(data, forKey: key, expiry: expiry)
  }
  
  public func setData(data: Data, key: String, expiry: Expiry) throws {
    try storage.setObject(data, forKey: .string(key), expiry: expiry)
  }
  
  public func setData(data: Data, request: URLRequest, expiry: Expiry) throws {
    try storage.setObject(data, forKey: .request(request), expiry: expiry)
  }
}

// GET Cache
extension DataProvider {
  public func cachedData(key: DataStoreKey) throws -> Data {
    try storage.object(forKey: key)
  }
  
  public func cachedData(key: String) throws -> Data {
    try cachedData(key: .string(key))
  }
  
  public func cachedData(urlRequest: URLRequest) throws -> Data {
    try cachedData(key: .request(urlRequest))
  }
}

// GET
extension DataProvider {
  public func data(key: DataStoreKey, expiry: Expiry) async throws -> Data {
    switch key {
    case .request(let urlRequest):
      try await self.data(request: urlRequest, expiry: expiry)
    case .string(let stringKey):
      try self.data(key: stringKey, expiry: expiry)
    }
  }
  
  public func data(key: String, expiry: Expiry) throws -> Data {
    let cachedData = try cachedData(key: .string(key))
    try storage.setObject(cachedData, forKey: .string(key), expiry: expiry)
    return cachedData
  }

  public func data(request: URLRequest, expiry: Expiry) async throws -> Data {
    let key: DataStoreKey = .request(request)
    
    // 1. Restore Data if exists in Cache
    if let cachedImage = try? cachedData(key: key) {
      try storage.setObject(cachedImage, forKey: .request(request))
      return cachedImage
    }
    
    // 2. Restore Task if already executed
    if let task = tasks[key] {
      return try await task.value
    }
    
    // 3. Fetch New Data
    let task = Task {
      do {
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
      } catch {
        tasks.removeValue(forKey: .request(request))
        throw error
      }
    }
    
    // 4. Store Task
    self.tasks[key] = task
    
    let data = try await task.value
    
    // 5. Store Data
    try setData(data: data, key: .request(request), expiry: expiry)
    
    // 6. Remove Task
    self.tasks.removeValue(forKey: key)
    
    return data
  }
}
