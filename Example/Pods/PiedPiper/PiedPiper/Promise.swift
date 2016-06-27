import Foundation

/// This class is a Future computation, where you can attach failure and success callbacks.
public class Promise<T>: Async {
  public typealias Value = T
  
  private var failureListeners: [(ErrorType) -> Void] = []
  private var successListeners: [(T) -> Void] = []
  private var cancelListeners: [Void -> Void] = []
  private var error: ErrorType?
  private var value: T?
  private var canceled = false
  private let successLock: ReadWriteLock = PThreadReadWriteLock()
  private let failureLock: ReadWriteLock = PThreadReadWriteLock()
  private let cancelLock: ReadWriteLock = PThreadReadWriteLock()
  
  /// The Future associated to this Promise
  private weak var _future: Future<T>?
  public var future: Future<T> {
    if let _future = _future {
      return _future
    }
    
    let newFuture = Future(promise: self)
    _future = newFuture
    return newFuture
  }
  
  /**
  Creates a new Promise
  */
  public init() {}
  
  convenience init(_ value: T) {
    self.init()
    
    succeed(value)
  }
  
  convenience init(value: T?, error: ErrorType) {
    self.init()
    
    if let value = value {
      succeed(value)
    } else {
      fail(error)
    }
  }
  
  convenience init(_ error: ErrorType) {
    self.init()
    
    fail(error)
  }
  
  /**
  Mimics the given Future, so that it fails or succeeds when the stamps does so (in addition to its pre-existing behavior)
  Moreover, if the mimiced Future is canceled, the Promise will also cancel itself
   
  - parameter stamp: The Future to mimic
   
  - returns: The Promise itself
  */
  public func mimic(stamp: Future<T>) -> Promise<T> {
    stamp.onCompletion { result in
      switch result {
      case .Success(let value):
        self.succeed(value)
      case .Error(let error):
        self.fail(error)
      case .Cancelled:
        self.cancel()
      }
    }
    
    return self
  }
  
  /**
  Mimics the given Result, so that it fails or succeeds when the stamps does so (in addition to its pre-existing behavior)
  Moreover, if the mimiced Result is canceled, the Promise will also cancel itself
   
  - parameter stamp: The Result to mimic
   
  - returns: The Promise itself
  */
  public func mimic(stamp: Result<T>) -> Promise<T> {
    switch stamp {
    case .Success(let value):
      self.succeed(value)
    case .Error(let error):
      self.fail(error)
    case .Cancelled:
      self.cancel()
    }
    
    return self
  }
  
  private func clearListeners() {
    successLock.withWriteLock {
      successListeners.removeAll()
    }
    
    failureLock.withWriteLock {
      failureListeners.removeAll()
    }
    
    cancelLock.withWriteLock {
      cancelListeners.removeAll()
    }
  }
  
  /**
  Makes the Promise succeed with a value
  
  - parameter value: The value found for the Promise
  
  Calling this method makes all the listeners get the onSuccess callback
  */
  public func succeed(value: T) {
    guard self.error == nil else { return }
    guard self.value == nil else { return }
    guard self.canceled == false else { return }
    
    self.value = value
    
    successLock.withReadLock {
      successListeners.forEach { listener in
        listener(value)
      }
    }
    
    clearListeners()
  }
  
  /**
  Makes the Promise fail with an error
  
  - parameter error: The optional error that caused the Promise to fail
  
  Calling this method makes all the listeners get the onFailure callback
  */
  public func fail(error: ErrorType) {
    guard self.error == nil else { return }
    guard self.value == nil else { return }
    guard self.canceled == false else { return }
    
    self.error = error
    
    failureLock.withReadLock {
      failureListeners.forEach { listener in
        listener(error)
      }
    }
    
    clearListeners()
  }
  
  /**
  Cancels the Promise
  
  Calling this method makes all the listeners get the onCancel callback (but not the onFailure callback)
  */
  public func cancel() {
    guard self.error == nil else { return }
    guard self.value == nil else { return }
    guard self.canceled == false else { return }
    
    canceled = true
    
    cancelLock.withReadLock {
      cancelListeners.forEach { listener in
        listener()
      }
    }
    
    clearListeners()
  }
  
  /**
  Adds a listener for the cancel event of this Promise
   
  - parameter cancel: The closure that should be called when the Promise is canceled
   
  - returns: The updated Promise
  */
  public func onCancel(callback: Void -> Void) -> Promise<T> {
    if canceled {
      callback()
    } else {
      cancelLock.withWriteLock {
        cancelListeners.append(callback)
      }
    }
    
    return self
  }
  
  /**
  Adds a listener for the success event of this Promise
  
  - parameter success: The closure that should be called when the Promise succeeds, taking the value as a parameter
  
  - returns: The updated Promise
  */
  public func onSuccess(callback: (T) -> Void) -> Promise<T> {
    if let value = value {
      callback(value)
    } else {
      successLock.withWriteLock {
        successListeners.append(callback)
      }
    }
    
    return self
  }
  
  /**
  Adds a listener for the failure event of this Promise
  
  - parameter success: The closure that should be called when the Promise fails, taking the error as a parameter
  
  - returns: The updated Promise
  */
  public func onFailure(callback: (ErrorType) -> Void) -> Promise<T> {
    if let error = error {
      callback(error)
    } else {
      failureLock.withWriteLock {
        failureListeners.append(callback)
      }
    }
    
    return self
  }
  
  /**
  Adds a listener for both success and failure events of this Promise
  
  - parameter completion: The closure that should be called when the Promise completes (succeeds or fails), taking a result with value .Success in case the Promise succeeded and .Error in case the Promise failed as parameter. If the Promise is canceled, the result will be .Cancelled
  
  - returns: The updated Promise
  */
  public func onCompletion(completion: (result: Result<T>) -> Void) -> Promise<T> {
    if let error = error {
      completion(result: .Error(error))
    } else if let value = value {
      completion(result: .Success(value))
    } else if canceled {
      completion(result: .Cancelled)
    } else {
      onSuccess { completion(result: .Success($0)) }
      onFailure { completion(result: .Error($0)) }
      onCancel { completion(result: .Cancelled) }
    }
    
    return self
  }
}
