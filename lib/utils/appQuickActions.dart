import 'package:quick_actions/quick_actions.dart';

import '../app/generalImports.dart';

class AppQuickActions {
  final QuickActions quickActions = const QuickActions();

  static void initAppQuickActions() {
    //

    AppQuickActions().quickActions.initialize((String shortcutType) {

      if (shortcutType == 'home') {
        AppQuickActions.navigateTo(index: 0);
      } else if (shortcutType == 'booking') {
        AppQuickActions.navigateTo(index: 1);
      } else if (shortcutType == 'services') {
        AppQuickActions.navigateTo(index: 2);
      } else {
        AppQuickActions.navigateTo(index: 3);
      }
    });
    //
  }

  static void navigateTo({required int index}) {
    Constant.bottomNavigationBarGlobalKey.currentState?.selectedIndexOfBottomNavigationBar.value =
        index;
    //
    Constant.bottomNavigationBarGlobalKey.currentState?.pageController.jumpToPage(index);
  }

  static void createAppQuickActions() {
    //
    AppQuickActions().quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(type: 'reviews', localizedTitle: 'Reviews', icon: 'reviews'),
      const ShortcutItem(type: 'services', localizedTitle: 'Service', icon: 'services'),
      const ShortcutItem(type: 'booking', localizedTitle: 'Booking', icon: 'booking'),
      const ShortcutItem(type: 'home', localizedTitle: 'Home', icon: 'home'),
    ]);
  }

  static void clearShortcutItems() {
    AppQuickActions().quickActions.clearShortcutItems();
  }
}
