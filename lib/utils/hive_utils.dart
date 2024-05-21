import '../app/generalImports.dart';

class HiveUtils {
  static String? getJWT() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken);
  }

  static AppTheme getCurrentTheme() {
    final current = Hive.box(HiveKeys.themeBox).get(HiveKeys.currentTheme);

    if (current == null) {
      return AppTheme.light;
    }
    if (current == 'light') {
      return AppTheme.light;
    }
    if (current == 'dark') {
      return AppTheme.dark;
    }
    return AppTheme.light;
  }

  static void setCurrentTheme(AppTheme theme) {
    String newTheme;
    if (theme == AppTheme.light) {
      newTheme = 'light';
    } else {
      newTheme = 'dark';
    }
    Hive.box(HiveKeys.themeBox).put(HiveKeys.currentTheme, newTheme);
  }

  static Future<void> setUserData(Map data) async {

    await Hive.box(HiveKeys.userDetailsBox).put("userDetails", data);
     }

  static Future<void> setJWT(String token) async {
    await Hive.box(HiveKeys.userDetailsBox).put('token', token);
  }

  // static UserDetailsModel getUserDetails() {
  //   return UserDetailsModel.fromMap(Map.from(Hive.box(HiveKeys.userDetailsBox).toMap()));
  // }

  static ProviderDetails getProviderDetails() {
    try {
      return ProviderDetails.fromJson(
          Map.from(Hive.box(HiveKeys.userDetailsBox).get("userDetails") ?? {}));
    } catch (_) {}
    return ProviderDetails();
  }

  static void setUserIsAuthenticated() {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, true);
  }

  static Future<void> setUserIsNotAuthenticated() async {
    await Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
  }

  static Future<void> setUserIsNotNew() {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, true);
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, false);
  }

  static bool isUserAuthenticated() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isAuthenticated) ?? false;
  }

  static bool isUserFirstTime() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserFirstTime) ?? false;
  }

  static Future<void> logoutUser({required VoidCallback onLogout}) async {
    await setUserIsNotAuthenticated();
    await Hive.box(HiveKeys.userDetailsBox).clear();
    onLogout.call();
  }

  static Future<void> clear() async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
  }
}
