import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color seed = Color(0xFF7C4DFF);
  static const Color surfaceTint = Color(0xFFF7F5FF);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
        surface: surfaceTint,
      ),
    );
    final text = GoogleFonts.notoSansLaoTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceTint,
        foregroundColor: base.colorScheme.onSurface,
        titleTextStyle: GoogleFonts.notoSansLao(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onSurface,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: base.colorScheme.outlineVariant),
        labelStyle: GoogleFonts.notoSansLao(fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      scaffoldBackgroundColor: surfaceTint,
    );
  }
}
