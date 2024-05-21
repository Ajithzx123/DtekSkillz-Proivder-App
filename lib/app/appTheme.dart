import 'package:flutter/material.dart';

import 'generalImports.dart';

enum AppTheme { dark, light }

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.light: ThemeData(
    scaffoldBackgroundColor: AppColors.lightPrimaryColor,
    brightness: Brightness.light,
    primaryColor:  AppColors.lightPrimaryColor,
    secondaryHeaderColor: AppColors.lightSubHeadingColor1,
    fontFamily: 'PlusJakartaSans',
    primarySwatch: AppColors.primarySwatchLightColor,
  ),
  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimaryColor,
    secondaryHeaderColor: AppColors.darkSubHeadingColor1,
    scaffoldBackgroundColor: AppColors.darkPrimaryColor,
    primarySwatch: AppColors.primarySwatchDarkColor,
    fontFamily: 'PlusJakartaSans',
  )
};
