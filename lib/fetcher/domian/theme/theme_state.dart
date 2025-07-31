part of 'theme_cubit.dart';

@immutable
abstract class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

class ThemeChanged extends ThemeState {
  const ThemeChanged(super.themeMode);
}
