import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  final String appName;
  final String version;
  final String buildNumber;

  const AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });
}

class AppInfoService {
  static late AppInfo _appInfo;

  static AppInfo get appInfo => _appInfo;

  /// Initializes the service by retrieving platform package information.
  /// This should be called before runApp() in main.dart.
  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _appInfo = AppInfo(
      appName: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }
}

/// Provider to synchronously access the cached AppInfo throughout the app.
final appInfoProvider = Provider<AppInfo>((ref) {
  return AppInfoService.appInfo;
});
