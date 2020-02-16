import Foundation

/// Thread safe dictionary for storage
public final class SafeDictionary<Key: Hashable, Value> {
    private let access = DispatchQueue(label: "\(SafeDictionary.self).access",
                                       qos: .utility,
                                       attributes: [.concurrent])
    private var storage = [Key: Value]()
    
    /// create a new SafeDictionary
    public init() {}
    
    /// Safely set a key to value.  If value is nil removes the key/value
    /// - parameters:
    ///     - key: key to set
    ///     - value: value to set key to
    public func set(_ key: Key, to value: Value?) {
        // remove the key if no value
        guard let value = value else {
            remove(key)
            return
        }
        // safely add the key, value to storage
        access.async(flags: [.barrier]) {
            self.storage[key] = value
        }
    }
    
    /// Safely remove the key/value from the storage
    /// - parameters:
    ///     - key: key to remove key/value
    public func remove(_ key: Key) {
        // safely remove the key and value from the storage
        access.async(flags: [.barrier]) { self.storage.removeValue(forKey: key) }
    }
    
    /// Safely get a value
    /// - parameters:
    ///     - key: key to get value of
    /// - returns: value in key of storage or nil if can not find key
    public func get(at key: Key) -> Value? {
        access.sync { storage[key] }
    }
    
    /// Safely get /set the value for key
    public subscript(key: Key) -> Value? {
        get { get(at: key) }
        set { set(key, to: newValue)}
    }
}
