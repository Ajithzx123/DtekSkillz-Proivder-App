// ignore_for_file: depend_on_referenced_packages

import 'package:edemand_partner/cubits/fetchPreviousSubscriptionsCubit.dart';
import 'package:edemand_partner/cubits/updateFCMCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generalImports.dart';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  //locked in portrait mode only
  SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  //
  FirebaseMessaging.onBackgroundMessage(NotificationService.onBackgroundMessageHandler);

  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  await Hive.initFlutter();
  await Hive.openBox(HiveKeys.userDetailsBox);
  await Hive.openBox(HiveKeys.authBox);
  await Hive.openBox(HiveKeys.languageBox);
  await Hive.openBox(HiveKeys.themeBox);

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_outlined,
            color: Colors.red,
            size: 100,
          ),
          Text(
            errorDetails.exception.toString(),
          ),
        ],
      ),
    );
  };

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationCubit>(
          create: (BuildContext context) => AuthenticationCubit(),
        ),
        BlocProvider<SignInCubit>(
          create: (BuildContext context) => SignInCubit(),
        ),
        BlocProvider<ProviderDetailsCubit>(
          create: (BuildContext context) => ProviderDetailsCubit(),
        ),
        BlocProvider<AppThemeCubit>(
          create: (BuildContext context) => AppThemeCubit(),
        ),
        BlocProvider<LanguageCubit>(
          create: (BuildContext context) => LanguageCubit(),
        ),
        BlocProvider<FetchBookingsCubit>(
          create: (BuildContext context) => FetchBookingsCubit(),
        ),
        BlocProvider<FetchServicesCubit>(
          create: (BuildContext context) => FetchServicesCubit(),
        ),
        BlocProvider<FetchServiceReviewsCubit>(
          create: (BuildContext context) => FetchServiceReviewsCubit(),
        ),
        BlocProvider<FetchServiceCategoryCubit>(
          create: (BuildContext context) => FetchServiceCategoryCubit(),
        ),
        BlocProvider(
          create: (context) => UpdateFCMCubit(),
        ),
        BlocProvider<CreatePromocodeCubit>(
          create: (BuildContext context) => CreatePromocodeCubit(),
        ),
        BlocProvider<UpdateBookingStatusCubit>(
          create: (BuildContext context) => UpdateBookingStatusCubit(),
        ),
        BlocProvider<FetchReviewsCubit>(
          create: (BuildContext context) => FetchReviewsCubit(),
        ),
        BlocProvider<DeleteServiceCubit>(
          create: (BuildContext context) => DeleteServiceCubit(),
        ),
        BlocProvider<TimeSlotCubit>(
          create: (BuildContext context) => TimeSlotCubit(),
        ),
        BlocProvider<FetchPromocodesCubit>(
          create: (BuildContext context) => FetchPromocodesCubit(),
        ),
        BlocProvider<FetchStatisticsCubit>(
          create: (BuildContext context) => FetchStatisticsCubit(),
        ),
        BlocProvider<FetchSystemSettingsCubit>(
          create: (BuildContext context) => FetchSystemSettingsCubit(),
        ),
        BlocProvider<DeleteAccountCubit>(
          create: (BuildContext context) => DeleteAccountCubit(),
        ),
        BlocProvider<CountryCodeCubit>(
          create: (BuildContext context) => CountryCodeCubit(),
        ),
        BlocProvider<AuthenticationCubit>(
          create: (BuildContext context) => AuthenticationCubit(),
        ),
        BlocProvider<VerifyPhoneNumberCubit>(
          create: (BuildContext context) => VerifyPhoneNumberCubit(),
        ),
        BlocProvider<VerifyOtpCubit>(
          create: (BuildContext context) => VerifyOtpCubit(),
        ),
        BlocProvider<CountryCodeCubit>(
          create: (BuildContext context) => CountryCodeCubit(),
        ),
        BlocProvider<ResendOtpCubit>(
          create: (BuildContext context) => ResendOtpCubit(),
        ),
        BlocProvider<ChangePasswordCubit>(
          create: (BuildContext context) => ChangePasswordCubit(),
        ),
        BlocProvider<FetchTaxesCubit>(
          create: (BuildContext context) => FetchTaxesCubit(),
        ),
        BlocProvider<FetchPreviousSubscriptionsCubit>(
          create: (context) => FetchPreviousSubscriptionsCubit(),
        ),
        BlocProvider<VerifyPhoneNumberFromAPICubit>(
          create: (BuildContext context) =>
              VerifyPhoneNumberFromAPICubit(authenticationRepository: AuthRepository()),
        ),
        BlocProvider<AddSubscriptionTransactionCubit>(
          create: (context) => AddSubscriptionTransactionCubit(),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    context.read<LanguageCubit>().loadCurrentLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme currentTheme = context.watch<AppThemeCubit>().state.appTheme;

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (BuildContext context, LanguageState languageState) {
        //unfocused and dismiss the keyboard when tapping outside of the form field
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: MaterialApp(
            title: Constant.appName,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: Routes.onGenerateRouted,
            initialRoute: Routes.splash,
            theme: appThemeData[currentTheme],
            builder: (BuildContext context, Widget? widget) {
              return ScrollConfiguration(behavior: GlobalScrollBehavior(), child: widget!);
            },
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: appLanguages.map((AppLanguage language) {
              return UiUtils.getLocaleFromLanguageCode(language.languageCode);
            }).toList(),
            locale: (languageState is LanguageLoader)
                ? Locale(languageState.languageCode)
                : Locale(Constant.defaultLanguageCode),
          ),
        );
      },
    );
  }
}

///To remove scroll-glow from the ListView/GridView etc..
class CustomScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

///To apply BouncingScrollPhysics() to every scrollable widget
class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
