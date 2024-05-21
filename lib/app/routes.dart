import 'package:edemand_partner/ui/screens/subscription/subscriptionHistory.dart';
import 'package:edemand_partner/ui/screens/subscription/subscription_confirmation.dart';
import 'package:flutter/material.dart';
import 'generalImports.dart';

class Routes {
  static const String splash = 'splash';
  static const String main = 'mainActivity';
  static const String language = 'language';
  static const String registration = 'registration';
  static const String createService = 'CreateService';
  static const String promoCode = 'Promocode';
  static const String addPromoCode = 'AddPromocode';
  static const String withdrawalRequests = 'withdrawalRequests';
  static const String cashCollection = 'cashCollection';
  static const String categories = 'Categories';
  static const String serviceDetails = 'ServiceDetails';
  static const String bookingDetails = 'BookingDetails';
  static const String loginScreenRoute = 'loginRoute';
  static const String appSettings = 'appSettings';
  static const String otpVerificationRoute = '/login/OtpVerification';
  static const String createNewPassword = '/createNewPassword';
  static const String maintenanceModeScreen = '/maintenanceModeScreen';
  static const String appUpdateScreen = '/appUpdateScreen';
  static const String imagePreviewScreen = '/imagePreviewScreen';
  static const String countryCodePickerRoute = '/countryCodePicker';
  static const String sendOTPScreen = '/sendOTPScreen';
  static const String providerRegistration = '/providerRegistration';
  static const String successScreen = '/successScreen';
  static const String settlementHistoryScreen = '/settlementHistoryScreen';
  static const String subscriptionScreen = '/subscriptionScreen';
  static const String paypalPaymentScreen = "/paypalPaymentScreen";
  static const String subscriptionPaymentConfirmationScreen =
      "/subscriptionPaymentConfirmationScreen";
  static const String previousSubscriptions = "/previousSubscriptions";

  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    currentRoute = routeSettings.name ?? '';

    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(
            builder: (BuildContext context) => const SplashScreen());

      case main:
        return MainActivity.route(routeSettings);

      case language:
        return ChangeLanguage.route(routeSettings);

      case registration:
        return RegistrationForm.route(routeSettings);

      case createService:
        return CreateService.route(routeSettings);

      case promoCode:
        return PromoCode.route(routeSettings);

      case addPromoCode:
        return AddPromoCode.route(routeSettings);

      case withdrawalRequests:
        return WithdrawalRequestsScreen.route(routeSettings);

      case cashCollection:
        return CashCollectionScreen.route(routeSettings);

      case categories:
        return Categories.route(routeSettings);

      case serviceDetails:
        return ServiceDetails.route(routeSettings);

      case bookingDetails:
        return BookingDetails.route(routeSettings);

      case loginScreenRoute:
        return LoginScreen.route(routeSettings);

      case appSettings:
        return AppSetting.route(routeSettings);

      case maintenanceModeScreen:
        return MaintenanceModeScreen.route(routeSettings);

      case appUpdateScreen:
        return AppUpdateScreen.route(routeSettings);

      case imagePreviewScreen:
        return ImagePreview.route(routeSettings);

      case countryCodePickerRoute:
        return CountryCodePickerScreen.route(routeSettings);

      case otpVerificationRoute:
        return OtpVerificationScreen.route(routeSettings);

      case createNewPassword:
        return CreateNewPassword.route(routeSettings);

      case sendOTPScreen:
        return SendOTPScreen.route(routeSettings);

      case providerRegistration:
        return ProviderRegistration.route(routeSettings);
      case settlementHistoryScreen:
        return SettlementHistoryScreen.route(routeSettings);

      case successScreen:
        return SuccessScreen.route(routeSettings);

      case subscriptionScreen:
        return SubscriptionsScreen.route(routeSettings);

      case paypalPaymentScreen:
        return PayPalPaymentScreen.route(routeSettings);

      // case subscriptionPaymentConfirmationScreen:
      //   return SubscriptionPaymentConfirmationScreen.route(routeSettings);

      // case previousSubscriptions:
      //   return SubscriptionHistoryScreen.route(routeSettings);

      default:
        return CupertinoPageRoute(
          builder: (BuildContext context) => Scaffold(
            body: CustomText(
              titleText: 'pageNotFoundErrorMsg'.translate(context: context),
            ),
          ),
        );
    }
  }
}
