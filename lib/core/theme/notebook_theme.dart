import 'package:flutter/material.dart';

class SourceTypeColors {
  final Color primary;
  final Color background;
  final Color border;

  const SourceTypeColors({
    required this.primary,
    required this.background,
    required this.border,
  });
}

class NotebookTheme {
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray900 = Color(0xFF111827);
  static const Color white = Color(0xFFFFFFFF);
  
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
  static const Color error = Color(0xFFEF4444);

  static final BorderRadius borderRadiusMd = BorderRadius.circular(8);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(16);

  static const Map<String, SourceTypeColors> sourceTypeColors = {
    'assignment': SourceTypeColors(
      primary: Color(0xFF6366F1),
      background: Color(0xFFEEF2FF),
      border: Color(0xFFC7D2FE),
    ),
    'report': SourceTypeColors(
      primary: Color(0xFF10B981),
      background: Color(0xFFECFDF5),
      border: Color(0xFFA7F3D0),
    ),
    'quiz': SourceTypeColors(
      primary: Color(0xFFF59E0B),
      background: Color(0xFFFFFBEB),
      border: Color(0xFFFDE68A),
    ),
    'reading': SourceTypeColors(
      primary: Color(0xFF8B5CF6),
      background: Color(0xFFF5F3FF),
      border: Color(0xFFDDD6FE),
    ),
    'essay': SourceTypeColors(
      primary: Color(0xFFEC4899),
      background: Color(0xFFFDF2F8),
      border: Color(0xFFFBCFE8),
    ),
    'doubt': SourceTypeColors(
      primary: Color(0xFF3B82F6),
      background: Color(0xFFEFF6FF),
      border: Color(0xFFBFDBFE),
    ),
    'classroom': SourceTypeColors(
      primary: Color(0xFF14B8A6),
      background: Color(0xFFF0FDFA),
      border: Color(0xFF99F6E4),
    ),
  };
}
