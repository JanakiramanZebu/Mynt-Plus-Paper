import 'package:flutter/foundation.dart';

abstract class DefaultChangeNotifier extends ChangeNotifier {
  bool loading = false;
  bool isLoad = true;
  bool fundisLoad = false;
  bool _disposed = false;
  bool fundLoading = false;

  /// Flag indicating if this notifier has been disposed
  bool get disposed => _disposed;

  String? errorMessage;
  bool initLoad = false;

  // ignore: avoid_positional_boolean_parameters

  // On/off loader mode If it takes longer than expected to retrieve data from the API,
  //we only activate loader on mode during that period.

  void toggleLoadingOn(bool on) {
    print("toggleLoadingOn: $on");
    loading = on;
    notifyListeners();
  }

  // ignore: avoid_positional_boolean_parameters
  void toggleLoad(bool on) {
    isLoad = on;
    notifyListeners();
  }
 
  void togglefundLoadingOn(bool on) {
    fundisLoad = on;
    print("togglefundLoadingOn: $on");
    notifyListeners();
  }

  void togglefundLoading(bool on) {
    fundLoading = on;
    print("togglefundLoading: $on");
    notifyListeners();
  }

  void setErrorMessage(String value) {
    errorMessage = value;
    notifyListeners();
  }

  void initLaod(bool on) {
    initLoad = on;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
