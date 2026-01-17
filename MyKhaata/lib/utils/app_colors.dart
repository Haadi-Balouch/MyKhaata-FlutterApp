import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

// This class is now deprecated in favor of using ThemeProvider.currentTheme
// Keep it for backward compatibility with existing code
class AppColors {
  static const Color yellowT = Color(0xFFEAE1A7);
  static const Color blackBG = Color(0xFF5A5A5A);
  static const Color scaffoldColor = Color(0xFF34343C);
}


extension CurrencyHelper on BuildContext {
  String get currency {
    try {
      return Provider.of<ThemeProvider>(this, listen: false).currencySymbol;
    } catch (e) {
      return 'Rs'; // Fallback
    }
  }
}

// Extension to get themed colors from BuildContext
extension ThemedColors on BuildContext {
  Color get primaryColor {
    // Access theme from provider if available
    try {
      final provider = Provider.of<ThemeProvider>(this, listen: false);
      return provider.currentTheme.yellowT;
    } catch (e) {
      return AppColors.yellowT;
    }
  }

  Color get backgroundColor {
    try {
      final provider = Provider.of<ThemeProvider>(this, listen: false);
      return provider.currentTheme.blackBG;
    } catch (e) {
      return AppColors.blackBG;
    }
  }

  Color get scaffoldBackground {
    try {
      final provider = Provider.of<ThemeProvider>(this, listen: false);
      return provider.currentTheme.scaffoldColor;
    } catch (e) {
      return AppColors.scaffoldColor;
    }
  }
}
