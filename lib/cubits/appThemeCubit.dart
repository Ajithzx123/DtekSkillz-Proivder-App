import '../../app/generalImports.dart';

class AppThemeCubit extends Cubit<ThemeState> {
  AppThemeCubit() : super(ThemeState(HiveUtils.getCurrentTheme()));

  void changeTheme(AppTheme appTheme) {
    HiveUtils.setCurrentTheme(appTheme);
    emit(ThemeState(appTheme));
  }

  //dev!
  void toggleTheme() {
    if (state.appTheme == AppTheme.dark) {
      HiveUtils.setCurrentTheme(AppTheme.light);

      emit(ThemeState(AppTheme.light));
    } else {
      HiveUtils.setCurrentTheme(AppTheme.dark);

      emit(ThemeState(AppTheme.dark));
    }
  }

  bool isDarkMode() {
    return state.appTheme == AppTheme.dark;
  }
}

class ThemeState {

  ThemeState(this.appTheme);
  final AppTheme appTheme;
}
