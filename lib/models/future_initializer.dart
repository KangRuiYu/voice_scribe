import 'package:flutter/foundation.dart';

/// Interface for objects that rely on asynchronous setup.
///
/// Should only be implemented by objects that single use, ie. after
/// [terminate] is called, there is no guarantee that method calls will work.
mixin FutureInitializer<T> {
  Future<T> _initializeFuture;
  Future<void> _terminateFuture;

  /// Called before use to do asynchronous setup.
  ///
  /// Can optionally take a map of arguments.
  /// Calling methods before the returned [Future] is finished may have
  /// unexpected effects.
  /// Is idempotent, ie. subsequent calls after the first call will have no
  /// effect, and will just return the previous result.
  /// Should not override this method.
  Future<T> initialize([Map<String, dynamic> args = const {}]) async {
    if (_initializeFuture != null) return _initializeFuture;
    _initializeFuture = onInitialize(args);
    return _initializeFuture;
  }

  /// Called when done using this object.
  ///
  /// Calling other methods after calling [terminate] may have unexpected
  /// effects.
  /// Is idempotent.
  /// If called before [initialize] is called, throws a [NotInitialized]
  /// exception.
  /// If called before [initialize] is finished, waits for its completion
  /// before proceeding.
  /// Should not override this method.
  Future<void> terminate() async {
    if (_initializeFuture == null) throw NotInitialized();
    if (_terminateFuture != null) return _terminateFuture;
    await _initializeFuture;
    _terminateFuture = onTerminate();
  }

  /// Used by methods to confirm that the object is ready, ie. is initialized
  /// and not terminated.
  @protected
  void assertReady() {
    if (_initializeFuture == null) throw NotInitialized();
    if (_terminateFuture != null) throw Terminated();
  }

  /// Method called by [initialize] to do asynchronous setup.
  ///
  /// Should not be called directly.
  /// It is recommended that subclasses mark implementations of [onInitialize]
  /// as @protected.
  @protected
  Future<T> onInitialize(Map<String, dynamic> args);

  /// Method called by [terminate] to do asynchronous cleanup.
  ///
  /// Should not be called directly.
  /// It is recommended that subclasses mark implementations of [onInitialize]
  /// as @protected.
  @protected
  Future<void> onTerminate();
}

/// Thrown when [FutureInitializer] has not been initialized prior to
/// a method call that relies on it.
class NotInitialized implements Exception {
  final String message;
  NotInitialized([this.message]);
}

/// Thrown when [FutureInitializer] has been terminated and a method call was
/// attempted.
class Terminated implements Exception {
  final String message;
  Terminated([this.message]);
}
