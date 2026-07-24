import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UpdateService {
  static Future<Map<String, dynamic>?> checkForUpdate() async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      return null;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection("app")
          .doc("android")
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;

      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;

      return {
        "currentVersion": currentVersion,
        "latestVersion": data["latestVersion"] ?? currentVersion,
        "downloadUrl": data["downloadUrl"] ?? "",
        "forceUpdate": data["forceUpdate"] ?? false,
        "whatsNew": data["whatsNew"] ?? "",
      };
    } catch (e) {
      return null;
    }
  }

  static Future<void> openDownload(String url) async {
    if (url.trim().isEmpty) return;

    final uri = Uri.parse(url.trim());

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}