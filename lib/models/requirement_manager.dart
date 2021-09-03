import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Represents an abstract concept of a requirement. Used to test an object
/// against a test.
///
/// Consists of:
/// (1) Update function that gets the latest object that will be tested against.
/// (2) Check function that is used to test whether the current object passes.
class Requirement<T> {
  final Future<T> Function() _updateFunction;
  final bool Function(T value) _testFunction;

  T get value => _value;
  T _value;

  Requirement({
    @required updateFunction,
    @required testFunction,
  })  : _updateFunction = updateFunction,
        _testFunction = testFunction,
        _value = null;

  /// Updates the value to the newest result from [_testFunction].
  ///
  /// If the value has changed, returns true.
  Future<bool> update() async {
    T newValue = await _updateFunction();
    bool changed = newValue != _value;
    _value = newValue;
    return changed;
  }

  /// Returns true if the current value passes the
  bool satisfied() {
    return _testFunction(_value);
  }
}

/// Provides methods to help update and evaluate the statuses of a list of
/// [Requirement]s.
class RequirementsManager extends ChangeNotifier {
  UnmodifiableMapView<String, Requirement> get requirements =>
      UnmodifiableMapView<String, Requirement>(_requirements);
  final Map<String, Requirement> _requirements;

  RequirementsManager([this._requirements = const {}]);

  /// Updates the values of all requirements in [requirements].
  ///
  /// If there has been a change to at least one requirement, then the function
  /// will complete as true.
  Future<bool> updateAll() async {
    bool aRequirementChanged = false;

    for (Requirement requirement in requirements.values) {
      bool requirementChanged = await requirement.update();
      if (aRequirementChanged == false) {
        aRequirementChanged = requirementChanged;
      }
    }

    return aRequirementChanged;
  }

  /// Updates the values of all requirements in [requirements] and calls
  /// [notifyListeners] if there has been a change to at least one requirement.
  Future<void> updateAllAndNotify() async {
    bool aRequirementChanged = await updateAll();
    if (aRequirementChanged) {
      notifyListeners();
    }
  }

  /// Returns the latest value of the requirement with the [requirementName].
  dynamic value(String requirementName) => _requirements[requirementName].value;

  /// Returns true if the requirement with the [requirementName] is
  /// currently satisfied.
  bool satisfied(String requirementName) =>
      _requirements[requirementName].satisfied();

  /// Returns true if all requirements in [requirements] are satisfied.
  bool allSatisfied() {
    return _requirements.values.every((Requirement r) => r.satisfied());
  }
}
