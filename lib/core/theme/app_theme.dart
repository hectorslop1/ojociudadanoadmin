import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionButton,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // Ya no necesitamos esta definición, ahora usamos AppColors.primaryDark

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Color de fondo oscuro
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark, // Usamos el color guinda para modo oscuro
        secondary: AppColors.actionButtonDark, // Dorado más claro para modo oscuro
        // Superficies más claras para mejor contraste
        surface: const Color(0xFF2D2D2D),
        surfaceContainerHighest: const Color(0xFF252525),
        error: AppColors.errorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimaryDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimaryDark),
        displayMedium: TextStyle(color: AppColors.textPrimaryDark),
        displaySmall: TextStyle(color: AppColors.textPrimaryDark),
        headlineMedium: TextStyle(color: AppColors.textPrimaryDark),
        headlineSmall: TextStyle(color: AppColors.textPrimaryDark),
        titleLarge: TextStyle(color: AppColors.textPrimaryDark),
        titleMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark.withValues(alpha: 179)), // 0.7 * 255 = 179
        labelLarge: TextStyle(color: AppColors.textPrimaryDark),
        labelMedium: TextStyle(color: AppColors.primaryDark.withAlpha(230)), // Alta opacidad para mejor legibilidad
        labelSmall: TextStyle(color: AppColors.textSecondaryDark.withValues(alpha: 179)), // 0.7 * 255 = 179
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryDark,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark, // Usamos el guinda claro para botones elevados
          foregroundColor: Colors.white, // Texto en blanco para mejor contraste
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark, // Texto en guinda claro
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark, // Texto en guinda claro
          side: BorderSide(color: AppColors.primaryDark), // Borde en guinda claro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.actionButton, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      // Configuración de tarjetas
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        shadowColor: Colors.black.withValues(alpha: 0.2),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.actionButtonDark, // Dorado más claro para modo oscuro
        unselectedItemColor: AppColors.textSecondaryDark,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[800],
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
