import 'package:flutter/material.dart';

/// Registers callbacks to app life cycle changes.
///
/// Will not start observing for changes until [startObserving] is called.
/// If app detaches, it will automatically stop observing.
class AppLifeCycleObserver with WidgetsBindingObserver {
  final VoidCallback onDetached;
  final VoidCallback onInactive;
  final VoidCallback onPaused;
  final VoidCallback onResumed;

  bool _observing = false;

  AppLifeCycleObserver({
    this.onDetached = voidCallback,
    this.onInactive = voidCallback,
    this.onPaused = voidCallback,
    this.onResumed = voidCallback,
  });

  /// Registers this object [WidgetsBinding].
  ///
  /// If already [_observing], nothing happens.
  void startObserving() {
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  /// De-registers this object from [WidgetsBinding].
  void stopObserving() {
    if (!_observing) return;
    WidgetsBinding.instance.removeObserver(this);
    _observing = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.resumed:
        onResumed();
        break;
    }
  }

  static void voidCallback() => null;
}
