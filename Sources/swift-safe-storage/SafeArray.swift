import Foundation

/// Thread safe array for storage
class SafeArray<Value: Equatable> {
    private let access = DispatchQueue(label: "\(SafeArray.self).access",
                                       qos: .utility,
                                       attributes: [.concurrent])
    private var storage = [Value]()
    
    /// safely add a value to the storage
    /// - parameters:
    ///     - value: value to add to storage
    func add(_ value: Value) {
        insert(value, at: self.storage.endIndex)
    }
    
    /// safely insert a value at an index to the storage
    /// - parameters:
    ///     - value: value to add to storage
    ///     - at: index
    func insert(_ value: Value, at: Int) {
        access.async(flags: [.barrier]) {
            self.storage.insert(value, at: at)
        }
    }
    
    /// safely insert a value removing the previous value
    /// - parameters:
    ///     - value: value to add, removing previous
    func upsert(_ value: Value) {
        if let index = remove(value) {
            insert(value, at: index)
        } else {
            add(value)
        }
    }
    
    /// safely remove an item from the storage
    /// - parameters:
    ///     - at: indexof item to remove
    func remove(_ at: Int) {
        guard at < count else { return }
        access.async(flags: [.barrier]) {
            self.storage.remove(at: at)
        }
    }
    
    /// safely remove an item from the storage
    /// - parameters:
    ///     - value: value of item to remove
    /// - returns: the index that value was at
    func remove(_ value: Value) -> Int? {
        guard let index = find(value) else { return nil }
        remove(index)
        return index
    }
    
    /// safely get an item from the storage
    /// - parameters:
    ///     - at: the index of the value to get
    /// - returns: value at the index, or nil if the value does not exist
    func get(_ at: Int) -> Value? {
        access.sync { storage[at] }
    }
    
    /// safely find the index of the value
    /// - parameters:
    ///     - value: value to find the index of
    /// - returns: index of the value, or nil if the value does not exist
    func find(_ value: Value) -> Int? {
        access.sync { storage.firstIndex(where: { $0 == value }) }

    }
    
    /// safely get the size of the array
    var count: Int { access.sync { storage.count } }
    
    /// safely get the value at index
    subscript(index: Int) -> Value? { self.get(index) }
}
