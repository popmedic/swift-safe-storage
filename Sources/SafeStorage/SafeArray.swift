import Foundation

/// Thread safe array for storage
public final class SafeArray<Value> {
    private let access = DispatchQueue(label: "\(SafeArray.self).access",
                                       qos: .utility,
                                       attributes: [.concurrent])
    private var storage = [Value]()
    
    /// function type for checking if values are equal
    public typealias Equaling = (_ rhs: Value, _ lhs: Value) -> Bool
    
    /// create a new SafeArray
    public init() {}
    
    /// safely add a value to the storage
    /// - parameters:
    ///     - value: value to add to storage
    public func append(_ value: Value) {
        access.async(flags: [.barrier]) {
            self.storage.append(value)
        }
    }
    
    /// safely insert a value at an index to the storage
    /// - parameters:
    ///     - value: value to add to storage
    ///     - at: index, if index is greater then the current count,
    ///     will append instead
    public func insert(_ value: Value, at: Int) {
        access.async(flags: [.barrier]) {
            guard at < self.storage.count else {
                self.storage.append(value)
                return
            }
            self.storage.insert(value, at: at)
        }
    }
    
    /// safely insert a value removing the previous value
    /// - parameters:
    ///     - value: value to add, removing previous
    public func upsert(_ value: Value, isEqual: @escaping Equaling) {
        access.async(flags: [.barrier]) {
            if let index = self.storage.firstIndex(where: { isEqual($0, value) }){
                self.storage.remove(at: index)
                self.storage.insert(value, at: index)
            } else {
                self.storage.append(value)
            }
        }
    }
    
    /// remove an item from the storage
    /// - note: **NOT THREAD SAFE for safety use remove by value**
    /// - parameters:
    ///     - at: index of item to remove
    public func remove(_ at: Int) {
        access.async(flags: [.barrier]) {
            guard at < self.storage.count else { return }
            self.storage.remove(at: at)
        }
    }
    
    /// safely remove an item from the storage
    /// - parameters:
    ///     - value: value of item to remove
    ///     - isEqual: function to call to check if value is equal to
    ///                 value in storage
    /// - returns: the index that value was at
    public func remove(_ value: Value, isEqual: @escaping Equaling) {
        access.async(flags: [.barrier]) {
            guard let index = self.storage.firstIndex(where: { isEqual($0, value) }) else { return }
            self.storage.remove(at: index)
        }
    }
    
    /// get the item at index from the storage
    /// - note: **NOT THREAD SAFE, for thread safety use find**
    /// - parameters:
    ///     - at: the index of the value to get
    /// - returns: value at the index, or nil if the value does not exist
    public func get(_ at: Int) -> Value? {
        return access.sync {
            guard at < storage.count else { return nil }
            return storage[at]
        }
    }
    
    /// safely find the index of the value
    /// - parameters:
    ///     - value: value to find the index of
    ///     - isEqual: function to call to check if value is equal to
    ///                 value in storage
    /// - returns: index of the value, or nil if the value does not exist
    public func find(_ value: Value, isEqual: Equaling) -> Int? {
        access.sync { storage.firstIndex(where: { isEqual($0, value) }) }
    }
    
    /// safely get the size of the array
    public var count: Int { access.sync { storage.count } }
    
    /// safely get the value at index
    public subscript(index: Int) -> Value? { self.get(index) }
}
