import 'package:flutter/material.dart';

class AppColors {
  // Colores para modo claro
  static const Color primary = Color(0xFF612232); // Guinda
  static const Color secondary = Color(0xFFD3D3D3); // Gris
  static const Color background = Color(0xFFFFFFFF); // Blanco
  static const Color actionButton = Color(0xFFBFB07E); // Dorado
  
  // Colores para modo oscuro
  static const Color primaryDark = Color(0xFFAA4A5F); // Guinda más claro para modo oscuro
  static const Color secondaryDark = Color(0xFF505050); // Gris más oscuro para modo oscuro
  static const Color backgroundDark = Color(0xFF1E1E1E); // Fondo oscuro
  static const Color actionButtonDark = Color(0xFFD4C28C); // Dorado más claro para modo oscuro
  
  // Colores adicionales para la aplicación - Modo claro
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  
  // Colores adicionales para la aplicación - Modo oscuro
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Colores de estado que funcionan bien en ambos modos
  static const Color error = Color(0xFFE53935);
  static const Color errorDark = Color(0xFFFF5252);
  
  static const Color success = Color(0xFF43A047);
  static const Color successDark = Color(0xFF66BB6A);
  
  static const Color warning = Color(0xFFFFA000);
  static const Color warningDark = Color(0xFFFFB74D);
  
  static const Color info = Color(0xFF1E88E5);
  static const Color infoDark = Color(0xFF42A5F5);
  
  // Colores para estados de casos - Modo claro
  static const Color caseActive = Color(0xFF1E88E5); // Azul
  static const Color casePending = Color(0xFFFFA000); // Naranja
  static const Color caseResolved = Color(0xFF43A047); // Verde
  static const Color caseRejected = Color(0xFFE53935); // Rojo
  
  // Colores para estados de casos - Modo oscuro
  static const Color caseActiveDark = Color(0xFF42A5F5); // Azul más claro
  static const Color casePendingDark = Color(0xFFFFB74D); // Naranja más claro
  static const Color caseResolvedDark = Color(0xFF66BB6A); // Verde más claro
  static const Color caseRejectedDark = Color(0xFFFF5252); // Rojo más claro
  
  // Función para obtener el color adecuado según el modo
  static Color getColor(Color lightColor, Color darkColor, Brightness brightness) {
    return brightness == Brightness.light ? lightColor : darkColor;
  }
}
