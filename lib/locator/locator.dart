import 'package:get_it/get_it.dart';

import '../api/core/api_export.dart';
import '../api/core/api_link.dart';
import '../api/paper/paper_api_exporter.dart';
import 'preference.dart';

GetIt locator = GetIt.instance;

/// Set to true to enable paper trading mode.
/// When true, PaperApiExporter is registered instead of ApiExporter.
/// All order, portfolio, and fund calls will use local logic.
/// Market data (quotes, watchlists, charts) still uses real APIs.
bool isPaperTrading = true;

void setupLocator() {
  locator.registerLazySingleton(() => Preferences());
  locator.registerLazySingleton(() => ApiLinks());
  locator.registerLazySingleton<ApiExporter>(
    () => isPaperTrading ? PaperApiExporter() : ApiExporter(),
  );
}
