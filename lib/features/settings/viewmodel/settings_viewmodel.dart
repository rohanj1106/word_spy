import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/providers/player_progress_provider.dart';

class ThemeSettings {
  final String fontPreference; // 'poppins' | 'opendyslexic'
  final double textScale; // 0.85 | 1.0 | 1.15 | 1.3
  final bool highContrast;

  const ThemeSettings({
    this.fontPreference = 'poppins',
    this.textScale = 1.0,
    this.highContrast = false,
  });

  ThemeSettings copyWith({
    String? fontPreference,
    double? textScale,
    bool? highContrast,
  }) {
    return ThemeSettings(
      fontPreference: fontPreference ?? this.fontPreference,
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  final ProgressService _service;

  ThemeNotifier(this._service) : super(const ThemeSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final font = await _service.getFontPreference();
    final scale = await _service.getTextScale();
    final contrast = await _service.getHighContrast();
    state = ThemeSettings(
      fontPreference: font,
      textScale: scale,
      highContrast: contrast,
    );
  }

  Future<void> setFont(String font) async {
    await _service.setFontPreference(font);
    state = state.copyWith(fontPreference: font);
  }

  Future<void> setTextScale(double scale) async {
    await _service.setTextScale(scale);
    state = state.copyWith(textScale: scale);
  }

  Future<void> setHighContrast(bool enabled) async {
    await _service.setHighContrast(enabled);
    state = state.copyWith(highContrast: enabled);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier(ref.watch(progressServiceProvider));
});
