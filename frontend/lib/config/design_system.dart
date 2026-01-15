import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderaDesign {
  // --- Colors ---
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Violet
  static const Color accent = Color(0xFF10B981); // Emerald
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color danger = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500

  // --- Gradients ---
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Typography ---
  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    color: textSecondary,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  // --- Decorations ---
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.8),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withOpacity(0.3)),
  );

  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: bodyMedium.copyWith(color: textSecondary.withOpacity(0.5)),
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    );
  }
}
