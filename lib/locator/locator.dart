import 'package:get_it/get_it.dart';

import '../api/core/api_export.dart';
import '../api/core/api_link.dart';
import 'preference.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => Preferences());
  locator.registerLazySingleton(() => ApiLinks());
  locator.registerLazySingleton(() => ApiExporter());
}
