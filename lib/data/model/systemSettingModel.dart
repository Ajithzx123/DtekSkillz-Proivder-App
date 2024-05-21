class PaymentGatewaysSettings {
  PaymentGatewaysSettings({
    this.csrfTestName,
    this.razorpayApiStatus,
    this.razorpayMode,
    this.razorpayCurrency,
    this.razorpaySecret,
    this.razorpayKey,
    this.paystackStatus,
    this.paystackMode,
    this.paystackCurrency,
    this.paystackSecret,
    this.paystackKey,
    this.flutterWaveStatus,
    this.flutterPublicKey,
    this.flutterSecret,
    this.flutterEncryptionKey,
    this.webhookSecretKey,
    this.flutterwaveCurrencyCode,
    this.flutterWaveEndPointUrl,
    this.stripeStatus,
    this.stripeMode,
    this.stripeCurrency,
    this.stripePublishableKey,
    this.stripeWebhookSecretKey,
    this.stripeSecretKey,
    this.paypalStatus,
  });

  PaymentGatewaysSettings.fromJson(final Map<String, dynamic> json) {
    csrfTestName = json["csrf_test_name"];
    razorpayApiStatus = json["razorpayApiStatus"];
    razorpayMode = json["razorpay_mode"];
    razorpayCurrency = json["razorpay_currency"];
    razorpaySecret = json["razorpay_secret"];
    razorpayKey = json["razorpay_key"];
    paystackStatus = json["paystack_status"];
    paystackMode = json["paystack_mode"];
    paystackCurrency = json["paystack_currency"];
    paystackSecret = json["paystack_secret"];
    paystackKey = json["paystack_key"];
    flutterWaveStatus = json["flutter_wave_status"];
    flutterPublicKey = json["flutter_public_key"];
    flutterSecret = json["flutter_secret"];
    flutterEncryptionKey = json["flutter_encryption_key"];
    webhookSecretKey = json["webhook_secret_key"];
    flutterwaveCurrencyCode = json["flutterwave_currency_code"];
    flutterWaveEndPointUrl = json["flutter_wave_end_point_url"];
    stripeStatus = json["stripe_status"];
    stripeMode = json["stripe_mode"];
    stripeCurrency = json["stripe_currency"];
    stripePublishableKey = json["stripe_publishable_key"];
    stripeWebhookSecretKey = json["stripe_webhook_secret_key"];
    stripeSecretKey = json["stripe_secret_key"];
    paypalStatus = json["paypal_status"];
  }

  String? csrfTestName;
  String? razorpayApiStatus;
  String? razorpayMode;
  String? razorpayCurrency;
  String? razorpaySecret;
  String? razorpayKey;
  String? paystackStatus;
  String? paystackMode;
  String? paystackCurrency;
  String? paystackSecret;
  String? paystackKey;
  String? flutterWaveStatus;
  String? flutterPublicKey;
  String? flutterSecret;
  String? flutterEncryptionKey;
  String? webhookSecretKey;
  String? flutterwaveCurrencyCode;
  String? flutterWaveEndPointUrl;
  String? stripeStatus;
  String? stripeMode;
  String? stripeCurrency;
  String? stripePublishableKey;
  String? stripeWebhookSecretKey;
  String? stripeSecretKey;
  String? paypalStatus;
}

class GeneralSettings {
  GeneralSettings({
    this.companyTitle,
    this.supportName,
    this.supportEmail,
    this.phone,
    this.systemTimezoneGmt,
    this.systemTimezone,
    this.primaryColor,
    this.secondaryColor,
    this.primaryShadow,
    this.maxServiceableDistance,
    this.customerCurrentVersionAndroidApp,
    this.customerCurrentVersionIosApp,
    this.customerCompulsaryUpdateForceUpdate,
    this.providerCurrentVersionAndroidApp,
    this.providerCurrentVersionIosApp,
    this.providerCompulsaryUpdateForceUpdate,
    this.customerAppMaintenanceStartDate,
    this.customerAppMaintenanceEndDate,
    this.messageForCustomerApplication,
    this.customerAppMaintenanceMode,
    this.providerAppMaintenanceStartDate,
    this.providerAppMaintenanceEndDate,
    this.messageForProviderApplication,
    this.providerAppMaintenanceMode,
    this.countryCurrencyCode,
    this.currency,
    this.decimalPoint,
    this.address,
    this.shortDescription,
    this.copyrightDetails,
    this.supportHours,
    this.favicon,
    this.logo,
    this.halfLogo,
    this.partnerFavicon,
    this.partnerLogo,
    this.partnerHalfLogo,
    this.atDoorStepOptionAvailable,
    this.atStoreOptionAvailable,
    this.isOrderOTPConfirmationEnable,
  });

  GeneralSettings.fromJson(Map<String, dynamic> json) {
    companyTitle = json['company_title'];
    supportName = json['support_name'];
    supportEmail = json['support_email'];
    phone = json['phone'];
    systemTimezoneGmt = json['system_timezone_gmt'];
    systemTimezone = json['system_timezone'];
    primaryColor = json['primary_color'];
    secondaryColor = json['secondary_color'];
    primaryShadow = json['primary_shadow'];
    maxServiceableDistance = json['max_serviceable_distance'];
    customerCurrentVersionAndroidApp = json['customer_current_version_android_app'];
    customerCurrentVersionIosApp = json['customer_current_version_ios_app'];
    customerCompulsaryUpdateForceUpdate = json['customer_compulsary_update_force_update'];
    providerCurrentVersionAndroidApp = json['provider_current_version_android_app'];
    providerCurrentVersionIosApp = json['provider_current_version_ios_app'];
    providerCompulsaryUpdateForceUpdate = json['provider_compulsary_update_force_update'];
    customerAppMaintenanceStartDate = json['customer_app_maintenance_start_date'];
    customerAppMaintenanceEndDate = json['customer_app_maintenance_end_date'];
    messageForCustomerApplication = json['message_for_customer_application'];
    customerAppMaintenanceMode = json['customer_app_maintenance_mode'];
    providerAppMaintenanceStartDate = json['provider_app_maintenance_start_date'];
    providerAppMaintenanceEndDate = json['provider_app_maintenance_end_date'];
    messageForProviderApplication = json['message_for_provider_application'];
    providerAppMaintenanceMode = json['provider_app_maintenance_mode'];
    countryCurrencyCode = json['country_currency_code'];
    currency = json['currency'];
    isOrderOTPConfirmationEnable = json['otp_system'];
    decimalPoint = json['decimal_point'];
    address = json['address'];
    shortDescription = json['short_description'];
    copyrightDetails = json['copyright_details'];
    supportHours = json['support_hours'];
    favicon = json['favicon'];
    logo = json['logo'];
    halfLogo = json['half_logo'];
    partnerFavicon = json['partner_favicon'];
    partnerLogo = json['partner_logo'];
    partnerHalfLogo = json['partner_half_logo'];
    atStoreOptionAvailable = json['at_store'];
    atDoorStepOptionAvailable = json['at_doorstep'];
  }

  String? companyTitle;
  String? supportName;
  String? supportEmail;
  String? phone;
  String? systemTimezoneGmt;
  String? systemTimezone;
  String? isOrderOTPConfirmationEnable;
  String? primaryColor;
  String? secondaryColor;
  String? primaryShadow;
  String? maxServiceableDistance;
  String? customerCurrentVersionAndroidApp;
  String? customerCurrentVersionIosApp;
  String? customerCompulsaryUpdateForceUpdate;
  String? providerCurrentVersionAndroidApp;
  String? providerCurrentVersionIosApp;
  String? providerCompulsaryUpdateForceUpdate;
  String? customerAppMaintenanceStartDate;
  String? customerAppMaintenanceEndDate;
  String? messageForCustomerApplication;
  String? customerAppMaintenanceMode;
  String? providerAppMaintenanceStartDate;
  String? providerAppMaintenanceEndDate;
  String? messageForProviderApplication;
  String? providerAppMaintenanceMode;
  String? countryCurrencyCode;
  String? currency;
  String? decimalPoint;
  String? address;
  String? shortDescription;
  String? copyrightDetails;
  String? supportHours;
  String? favicon;
  String? logo;
  String? halfLogo;
  String? partnerFavicon;
  String? partnerLogo;
  String? partnerHalfLogo;
  String? atStoreOptionAvailable;
  String? atDoorStepOptionAvailable;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> SystemSettings = <String, dynamic>{};
    SystemSettings['company_title'] = companyTitle;
    SystemSettings['support_name'] = supportName;
    SystemSettings['support_email'] = supportEmail;
    SystemSettings['phone'] = phone;
    SystemSettings['system_timezone_gmt'] = systemTimezoneGmt;
    SystemSettings['system_timezone'] = systemTimezone;
    SystemSettings['primary_color'] = primaryColor;
    SystemSettings['secondary_color'] = secondaryColor;
    SystemSettings['primary_shadow'] = primaryShadow;
    SystemSettings['max_serviceable_distance'] = maxServiceableDistance;
    SystemSettings['customer_current_version_android_app'] = customerCurrentVersionAndroidApp;
    SystemSettings['customer_current_version_ios_app'] = customerCurrentVersionIosApp;
    SystemSettings['customer_compulsary_update_force_update'] = customerCompulsaryUpdateForceUpdate;
    SystemSettings['provider_current_version_android_app'] = providerCurrentVersionAndroidApp;
    SystemSettings['provider_current_version_ios_app'] = providerCurrentVersionIosApp;
    SystemSettings['provider_compulsary_update_force_update'] = providerCompulsaryUpdateForceUpdate;
    SystemSettings['customer_app_maintenance_start_date'] = customerAppMaintenanceStartDate;
    SystemSettings['customer_app_maintenance_end_date'] = customerAppMaintenanceEndDate;
    SystemSettings['message_for_customer_application'] = messageForCustomerApplication;
    SystemSettings['customer_app_maintenance_mode'] = customerAppMaintenanceMode;
    SystemSettings['provider_app_maintenance_start_date'] = providerAppMaintenanceStartDate;
    SystemSettings['provider_app_maintenance_end_date'] = providerAppMaintenanceEndDate;
    SystemSettings['message_for_provider_application'] = messageForProviderApplication;
    SystemSettings['provider_app_maintenance_mode'] = providerAppMaintenanceMode;
    SystemSettings['country_currency_code'] = countryCurrencyCode;
    SystemSettings['currency'] = currency;
    SystemSettings['decimal_point'] = decimalPoint;
    SystemSettings['address'] = address;
    SystemSettings['short_description'] = shortDescription;
    SystemSettings['copyright_details'] = copyrightDetails;
    SystemSettings['support_hours'] = supportHours;
    SystemSettings['favicon'] = favicon;
    SystemSettings['logo'] = logo;
    SystemSettings['half_logo'] = halfLogo;
    SystemSettings['partner_favicon'] = partnerFavicon;
    SystemSettings['partner_logo'] = partnerLogo;
    SystemSettings['partner_half_logo'] = partnerHalfLogo;
    return SystemSettings;
  }
}
