// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  final String termsAndConditions;
  final String privacyPolicy;
  final String aboutUs;
  final String contactUs;
  final String availableAmount;
  final String isDemoModeEnable;
  final GeneralSettings generalSettings;
  final PaymentGatewaysSettings paymentGatewaysSettings;
  final SubscriptionInformation subscriptionInformation;

  FetchSystemSettingsSuccess({
    required this.termsAndConditions,
    required this.privacyPolicy,
    required this.aboutUs,
    required this.contactUs,
    required this.availableAmount,
    required this.isDemoModeEnable,
    required this.paymentGatewaysSettings,
    required this.generalSettings,
    required this.subscriptionInformation,
  });

  FetchSystemSettingsSuccess copyWith({
    String? termsAndConditions,
    String? privacyPolicy,
    String? aboutUs,
    String? contactUs,
    String? availableAmount,
    GeneralSettings? generalSettings,
    PaymentGatewaysSettings? paymentGatewaysSettings,
    SubscriptionInformation? subscriptionInformation,
  }) {
    return FetchSystemSettingsSuccess(
      generalSettings: generalSettings ?? this.generalSettings,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      aboutUs: aboutUs ?? this.aboutUs,
      contactUs: contactUs ?? this.contactUs,
      isDemoModeEnable: isDemoModeEnable,
      availableAmount: availableAmount ?? this.availableAmount,
      paymentGatewaysSettings: paymentGatewaysSettings ?? this.paymentGatewaysSettings,
      subscriptionInformation: subscriptionInformation ?? this.subscriptionInformation,
    );
  }
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  final String errorMessage;

  FetchSystemSettingsFailure(this.errorMessage);
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState> {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());
  final SettingsRepository _settingsRepository = SettingsRepository();

  Future<void> getSettings({required bool isAnonymous}) async {
    try {
      emit(FetchSystemSettingsInProgress());
      final result = await _settingsRepository.getSystemSettings(isAnonymous: isAnonymous);
      //
      emit(
        FetchSystemSettingsSuccess(
          generalSettings: GeneralSettings.fromJson(result['general_settings'] ?? {}),
          privacyPolicy: result['privacy_policy']['privacy_policy'] ?? "",
          aboutUs: result['about_us']['about_us'] ?? "",
          availableAmount: result['balance'] ?? '',
          isDemoModeEnable: result['demo_mode'] ?? '0',
          termsAndConditions: result['terms_conditions']['terms_conditions'] ?? "",
          contactUs: result['contact_us']['contact_us'] ?? "",
          subscriptionInformation: result["subscription_information"] != null
              ? SubscriptionInformation.fromJson(
                  Map.from(result["subscription_information"] ?? {}))
              : SubscriptionInformation(),
          paymentGatewaysSettings:
              PaymentGatewaysSettings.fromJson(result["payment_gateways_settings"] ?? {}),
        ),
      );
    } catch (e) {
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  bool isOrderOTPVerificationEnable() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).generalSettings.isOrderOTPConfirmationEnable ==
          '1';
    }
    return true;
  }
  bool isDoorstepOptionAvailable() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).generalSettings.atDoorStepOptionAvailable ==
          '1';
    }
    return true;
  }
  bool isStoreOptionAvailable() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).generalSettings.atStoreOptionAvailable ==
          '1';
    }
    return true;
  }

  void updateAmount(String amount) {
    if (state is FetchSystemSettingsSuccess) {
      emit((state as FetchSystemSettingsSuccess).copyWith(availableAmount: amount));
    }
  }

  bool isDemoModeEnable() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).isDemoModeEnable == '1';
    }
    return false;
  }

  PaymentGatewaysSettings getPaymentMethodSettings() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).paymentGatewaysSettings;
    }
    return PaymentGatewaysSettings();
  }
}
