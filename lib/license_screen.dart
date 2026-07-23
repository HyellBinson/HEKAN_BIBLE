import 'package:flutter/material.dart';
import 'responsive.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LicensePage(
      applicationName: "HEKAN Bible",
      applicationVersion: "Version 1.0.0",
      applicationLegalese: "© 2026 HEKAN Nigeria\nAll Rights Reserved.",
      applicationIcon: Padding(
        padding: EdgeInsets.all(12 * scale),
        child: Image.asset(
          "assets/icon/app_icon.png",
          width: 70 * scale,
          height: 70 * scale,
        ),
      ),
    );
  }
}