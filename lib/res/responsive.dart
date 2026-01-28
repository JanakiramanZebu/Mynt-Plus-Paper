/// Responsive design system exports for Mynt-Plus
///
/// Import this file to get all responsive utilities:
/// ```dart
/// import 'package:mynt_plus/res/responsive.dart';
///
/// // Use breakpoints
/// if (AppBreakpoints.isMobile(context)) { ... }
///
/// // Use extensions
/// if (context.isMobile) { ... }
/// final padding = context.responsive(mobile: 16.0, desktop: 32.0);
///
/// // Use size calculations
/// final panelWidth = ResponsiveSizes.watchlistPanelWidth(context);
/// ```
library;

export 'app_breakpoints.dart';
export 'responsive_extensions.dart';
export 'responsive_sizes.dart';
