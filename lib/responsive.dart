import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  // Screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // Screen height
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Scale factor
  static double scale(BuildContext context) {
    final w = width(context);

    if (w < 360) return 0.85;      // Very small phones
    if (w < 390) return 0.92;      // Small phones
    if (w < 430) return 1.0;       // Normal phones
    if (w < 600) return 1.08;      // Large phones

    return 1.25;                   // Tablets
  }

  static bool isSmall(BuildContext context) =>
      width(context) < 360;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600;

  // Common sizes
  static double padding(BuildContext context) =>
      20 * scale(context);

  static double radius(BuildContext context) =>
      28 * scale(context);

  static double icon(BuildContext context) =>
      36 * scale(context);

  static double title(BuildContext context) =>
      22 * scale(context);

  static double subtitle(BuildContext context) =>
      16 * scale(context);

  static double body(BuildContext context) =>
      15 * scale(context);

  static double verse(BuildContext context) =>
      20.5 * scale(context);
}