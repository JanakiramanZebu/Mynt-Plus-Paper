// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/version_model/version_mod.dart';
import '../screens/Mobile/version_ui/version_ui.dart';
import 'core/default_change_notifier.dart';

final versionProvider =
    ChangeNotifierProvider((ref) => VersionProvider(ref));

class VersionProvider extends DefaultChangeNotifier {
  final Preferences pref = locator<Preferences>();
  final Ref ref;
  final api = locator<ApiExporter>();
  VersionProvider(this.ref);

  VersionModel? _versionModel;
  VersionModel? get versionmodel => _versionModel;

  String? _version = '';
  String? get version => _version;

  Future checkVersion(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      _version = packageInfo.version;
      _versionModel = await api.getVersionApi();
      // Compare versions
      if (_isNewerVersion(
          currentVersion,
          defaultTargetPlatform == TargetPlatform.iOS
              ? versionmodel!.attributes.version.ios
              : versionmodel!.attributes.version.android)) {
        // Show alert if current version is newer
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          backgroundColor: const Color(0xffffffff),
          isDismissible: false,
          enableDrag: false,
          showDragHandle: false,
          useSafeArea: false,
          isScrollControlled: true,
          builder: (context) => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
              child: VersionBottomSheet()),
        );
      }
    } catch (e) {}
  }

  bool _isNewerVersion(String currentVersion, String updatedversion) {
    int update = int.parse(updatedversion.replaceAll('.', ''));
    int current = int.parse(currentVersion.replaceAll('.', ''));

    print('completed ${update > current}  ${update} ${current}');
    return update > current;
  }
}
