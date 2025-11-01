import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_theme.dart';
import 'theme_state.dart';


class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(AppTheme.dark));

  void switchToDark() => emit(ThemeState(AppTheme.dark));
  void switchToLight() => emit(ThemeState(AppTheme.light));
  void toggle() {
    if (state.themeData.brightness == Brightness.dark) {
      emit(ThemeState(AppTheme.light));
    } else {
      emit(ThemeState(AppTheme.dark));
    }
  }
}
