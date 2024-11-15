import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'theme_notifier.g.dart';

enum ThemeModeState { light, dark }

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeModeState build() => ThemeModeState.light;

  void toggleTheme() {
    state = state == ThemeModeState.light
        ? ThemeModeState.dark
        : ThemeModeState.light;
  }
}
