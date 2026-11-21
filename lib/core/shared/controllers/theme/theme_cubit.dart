import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../safe_emit.dart';

import '../../../network/local/cache/cache_helper.dart';
import '../../../helper/app_navigator.dart';
import '../../../style/app_theme.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> with SafeEmit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());

  static ThemeCubit get(BuildContext context) => BlocProvider.of(context);

  ThemeMode? mode;
  bool isDark = false;

  Future getSettings() async {
    final String theme = await CacheHelper.get('theme')??"light";
    if (theme == 'dark') {
      mode = ThemeMode.dark;
      isDark = true;
    } else if (theme == 'light') {
      mode = ThemeMode.light;
      isDark = false;
    }
    emit(ThemeInitial());
    // Widgets reading an AppColors getter don't depend on Theme.of, so the
    // new MaterialApp theme alone never reaches them (F19).
    WidgetsBinding.instance.addPostFrameCallback((_) => AppTheme.rebuildAll());
  }
}

void changeThemeMode() {
  final bool isDark = CacheHelper.get('theme') == 'dark';
  CacheHelper.save('theme', isDark ? 'light' : 'dark');
  final context = AppNavigator.key.currentState!.context;
  ThemeCubit.get(context).getSettings();
  restartApplication();
}

void restartApplication() {
  ///TODO: Hand This Problem
}

class ThemeChangeObserver extends WidgetsBindingObserver {
  @override
  void didChangePlatformBrightness() {}
}
