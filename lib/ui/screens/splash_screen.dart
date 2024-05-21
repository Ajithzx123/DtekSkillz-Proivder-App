// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      //
      try {
        context
            .read<ProviderDetailsCubit>()
            .setUserInfo(HiveUtils.getProviderDetails());
        //
        context
            .read<FetchSystemSettingsCubit>()
            .getSettings(isAnonymous: false);
        //
        context.read<CountryCodeCubit>().loadAllCountryCode(context);
        //
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
              statusBarColor: AppColors.splashScreenGradientTopColor,
              systemNavigationBarColor:
                  AppColors.splashScreenGradientBottomColor,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.light),
        );
      } catch (_) {}
    });
  }

  void checkIsUserAuthenticated({required bool isNeedToShowAppUpdate}) {
    Future.delayed(const Duration(seconds: 2)).then((value) {
      //
      final AuthenticationState authenticationState =
          context.read<AuthenticationCubit>().state;

      if (authenticationState == AuthenticationState.authenticated) {
        if (context
                .read<ProviderDetailsCubit>()
                .providerDetails
                .providerInformation
                ?.isApproved ==
            '1') {
          //0-pending 1-success 2-failed
          if (context
                  .read<ProviderDetailsCubit>()
                  .providerDetails
                  .subscriptionInformation
                  ?.isSubscriptionActive ==
              "active") {
            Navigator.of(context).pushReplacementNamed(Routes.main);
          } else {
            // Navigator.of(context).pushReplacementNamed(
            //   Routes.screen,
            //   arguments: {"from": "splash"},
            // );
            Navigator.of(context).pushReplacementNamed(Routes.main);
          }
        } else if (context
                .read<ProviderDetailsCubit>()
                .providerDetails
                .providerInformation
                ?.isApproved ==
            '2') {
          Navigator.pushReplacementNamed(
            context,
            Routes.registration,
            arguments: {'isEditing': false},
          );
        } else {
          Navigator.of(context).pushReplacementNamed(Routes.loginScreenRoute);
        }
      } else if (authenticationState == AuthenticationState.unAuthenticated) {
        Navigator.of(context).pushReplacementNamed(Routes.loginScreenRoute);
      } else if (authenticationState == AuthenticationState.firstTime) {}

      if (isNeedToShowAppUpdate) {
        //if need to show app update screen then
        // we will push update screen, with not now button option
        Navigator.pushNamed(
          context,
          Routes.appUpdateScreen,
          arguments: {'isForceUpdate': false},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (BuildContext context, FetchSystemSettingsState state) async {
          if (state is FetchSystemSettingsSuccess) {
            //update provider subscription information, backup for get latest payment method
            final SubscriptionInformation subscriptionInformation =
                state.subscriptionInformation;
            context.read<ProviderDetailsCubit>().updateProviderDetails(
                subscriptionInformation: subscriptionInformation);
            //
            final GeneralSettings generalSettings = state.generalSettings;
            //
            // assign currency values
            Constant.systemCurrency = generalSettings.currency;
            Constant.systemCurrencyCountryCode =
                generalSettings.countryCurrencyCode;
            Constant.decimalPointsForPrice = generalSettings.decimalPoint;

            //
            // if maintenance mode is enable then we will redirect to maintenance mode screen
            if (generalSettings.providerAppMaintenanceMode == '1') {
              Navigator.pushReplacementNamed(
                context,
                Routes.maintenanceModeScreen,
                arguments: generalSettings.messageForProviderApplication,
              );
              return;
            }

            // here we will check current version and updated version from panel
            // if application current version is less than updated version then
            // we will show app update screen

            final String? latestAndroidVersion =
                generalSettings.providerCurrentVersionAndroidApp;
            final String? latestIOSVersion =
                generalSettings.providerCurrentVersionIosApp;

            final PackageInfo packageInfo = await PackageInfo.fromPlatform();

            final String currentApplicationVersion = packageInfo.version;

            final Version currentVersion =
                Version.parse(currentApplicationVersion);
            final Version latestVersionAndroid =
                Version.parse(latestAndroidVersion ?? '1.0.0');
            final Version latestVersionIos =
                Version.parse(latestIOSVersion ?? '1.0.0');

            if ((Platform.isAndroid && latestVersionAndroid > currentVersion) ||
                (Platform.isIOS && latestVersionIos > currentVersion)) {
              // If it is force update then we will show app update with only Update button
              if (generalSettings.providerCompulsaryUpdateForceUpdate == '1') {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.appUpdateScreen,
                  arguments: {'isForceUpdate': true},
                );
                return;
              } else {
                // If it is normal update then
                // we will pass true here for isNeedToShowAppUpdate
                checkIsUserAuthenticated(isNeedToShowAppUpdate: true);
              }
            } else {
              //if no update available then we will pass false here for isNeedToShowAppUpdate
              checkIsUserAuthenticated(isNeedToShowAppUpdate: false);
            }
          }
        },
        builder: (BuildContext context, FetchSystemSettingsState state) {
          if (state is FetchSystemSettingsFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: state.errorMessage.translate(context: context),
                onTapRetry: () {
                  context
                      .read<FetchSystemSettingsCubit>()
                      .getSettings(isAnonymous: false);
                },
              ),
            );
          }
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.splashScreenGradientTopColor,
                      AppColors.splashScreenGradientBottomColor,
                    ],
                    stops: [0, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                child: Center(
                  child: SvgPicture.asset(
                    '${Constant.svgPath}logo_partner_tetet-01.svg',
                    height: 240,
                    width: 220,
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 50),
              //   child: Align(
              //     alignment: Alignment.bottomCenter,
              //     child: SvgPicture.asset(
              //       '${Constant.svgPath}wrteam_logo.svg',
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
