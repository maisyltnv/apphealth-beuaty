import 'package:flutter/material.dart';

/// Brand palette — matches `health-and-beauty-web/app/globals.css`
/// (Emerald primary #064E3B + Amber/Gold secondary #F59E0B).
abstract final class AppColors {
  static const Color primary = Color(0xFF064E3B);
  static const Color primaryDark = Color(0xFF043D2E);
  static const Color primaryLight = Color(0xFF059669);
  static const Color primaryDeep = Color(0xFF022C22);

  /// Amber / gold — cart badges, highlights (web `--secondary`).
  static const Color secondary = Color(0xFFF59E0B);
  static const Color onSecondary = Color(0xFF1C1917);

  /// Light green tint for chips, highlights (web `--accent`).
  static const Color accent = Color(0xFFECFDF5);
  static const Color accentForeground = Color(0xFF065F46);

  static const Color background = Color(0xFFFAFAF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0FDF4);

  static const Color textPrimary = Color(0xFF1A2E26);
  static const Color textSecondary = Color(0xFF4B6358);
  static const Color textMuted = Color(0xFF7A9189);

  static const Color border = Color(0xFFE2E8E5);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  /// Newsletter / footer style block on web.
  static const LinearGradient promoGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, Color(0xFF047857)],
  );

  static const LinearGradient cardShine = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00FFFFFF), Color(0x0D000000)],
  );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
