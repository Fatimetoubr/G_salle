import 'package:flutter/material.dart';

class AppColors {
  static const Color primary       = Color(0xFF3A503C);
  static const Color primaryDark   = Color(0xFF1C4737);
  static const Color primaryDeep   = Color(0xFF1C4B2F);
  static const Color primaryLight  = Color(0xFF698A6C);
  static const Color accent        = Color(0xFF5FA77C);
  static const Color accentDark    = Color(0xFF4E8E68);
  static const Color accentLight   = Color(0xFFADDABA);
  static const Color borderSide    = Color(0xFF4A6350);
  static const Color background    = Color(0xFFF5F5F5);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textDark      = Color(0xFF333333);
  static const Color textGrey      = Color(0xFF666666);
  static const Color textLight     = Color(0xFFECF0F1);
  static const Color danger        = Color(0xFFC0392B);
  static const Color warning       = Color(0xFFF39C12);

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C4B2F), Color(0xFF1C4737)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5FA77C), Color(0xFF3A503C)],
  );

  static get success => null;
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.primary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      prefixIconColor: AppColors.primaryLight,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
  );
}
