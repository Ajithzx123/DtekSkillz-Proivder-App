import 'package:flutter/material.dart';

import '../app/generalImports.dart';

class Constant {
  static const String appName = 'Dtekskilz Partner';

  static const String svgPath = 'assets/images/svg/';
  static const String pngPath = 'assets/images/png/';

  static const String baseUrl = "https://admin.dtekskilz.com/partner/api/v1/";
//AAA
  // static const String baseUrl1 =
  //     'https://admin.spotserve.in/stage/partner/api/v1/';

  //global key
  static GlobalKey<MainActivityState> bottomNavigationBarGlobalKey =
      GlobalKey<MainActivityState>();

  //place API key
  static const String placeAPIKey = 'AIzaSyCNDMgtNJF3OmYwTFOMuB5rcWsaHy6QP9I';

  static const int resendOTPCountDownTime = 30; //in seconds

  static const int limit = 10;

  static String? systemCurrency;
  static String? systemCurrencyCountryCode;
  static String? decimalPointsForPrice;

//add your default country code here
  static String? defaultCountryCode = 'IN';

//if you do not want user to select another country rather than default country,
//then make below variable true
  static bool allowOnlySingleCountry = false;

  static const int animationDuration = 1; //value is in seconds
  //
  static String defaultLanguageCode = 'en';

  static const String playStoreApplicationLink =
      'https://play.google.com/store/apps/details?id=spot.serve.provider';

  static const String iosAppId = 'https://testflight.apple.com/join/n5tteGPs';

  //if you want to show onMap button on order details page to navigate to the map then make it true
  static bool showOnMapsButton = false;
}

//global key
GlobalKey<MainActivityState> mainActivityNavigationBarGlobalKey =
    GlobalKey<MainActivityState>();

//add  gradient color to show in the chart on home screen
List<LinearGradient> gradientColorForBarChart = [
  LinearGradient(
    colors: [Colors.green.shade300, Colors.green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Colors.blue.shade300, Colors.blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Colors.purple.shade300, Colors.purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

const List<AppLanguage> appLanguages = [
  //Please add language code here and language name and svg image in assets/images/svg/
  AppLanguage(
    languageCode: 'en',
    languageName: 'English',
    imageURL: 'america_flag',
  ),
  AppLanguage(
    languageCode: 'hi',
    languageName: 'हिन्दी - Hindi',
    imageURL: 'india_flag',
  ),
  AppLanguage(
    languageCode: 'ar',
    languageName: 'عربى - Arabic',
    imageURL: 'arab_flag',
  ),
];

// to manage snackBar/toast/message
enum MessageType { success, error, warning }

Map<MessageType, Color> messageColors = {
  MessageType.success: Colors.green,
  MessageType.error: Colors.red,
  MessageType.warning: Colors.orange
};

Map<MessageType, IconData> messageIcon = {
  MessageType.success: Icons.done_rounded,
  MessageType.error: Icons.error_outline_rounded,
  MessageType.warning: Icons.warning_amber_rounded
};

Map<String, dynamic> dateAndTimeSetting = {
  "dateFormat": "dd/MM/yyyy",
  "use24HourFormat": false
};
