import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionService {
  static Future<bool> checkForceUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Hardcode your first version
      final minRequiredVersion = '1.0.0';
      
      // Simple version comparison
      final needsUpdate = _compareVersions(currentVersion, minRequiredVersion) < 0;
      
      return needsUpdate;
    } catch (e) {
      return false;
    }
  }
  
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final diff = (parts1[i] ?? 0) - (parts2[i] ?? 0);
      if (diff != 0) return diff;
    }
    return 0;
  }
  
  static Future<void> openStore() async {
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.plantidentifier.nature.rose.identifier.plant';
    await launchUrl(Uri.parse(playStoreUrl));
  }
}