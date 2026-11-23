import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:game_list/core/constants/app_colors.dart';
import 'package:game_list/core/theme/app_theme.dart';

void main() {
  test('AppColors uses the required GameList palette', () {
    expect(AppColors.background, const Color(0xFF121212));
    expect(AppColors.accent, const Color(0xFF7C4DFF));
    expect(AppColors.highlight, const Color(0xFF00D4FF));
  });

  test('AppTheme builds a dark theme with the GameList background', () {
    final theme = AppTheme.darkTheme;

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.primary, AppColors.accent);
    expect(theme.colorScheme.secondary, AppColors.highlight);
  });
}

