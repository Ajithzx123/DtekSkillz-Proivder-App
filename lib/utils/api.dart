import 'package:flutter/foundation.dart';

import '../app/generalImports.dart';
import 'dart:developer' as log;

class ApiException implements Exception {
  ApiException(this.errorMessage);

  dynamic errorMessage;

  @override
  String toString() {
    return ErrorFilter.check(errorMessage).error;
  }
}

class Api {
  //headers
  static Map<String, dynamic> headers() {
    final String jwtToken =
        Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken) ?? "";
    if (kDebugMode) {
      print('token is $jwtToken');
    }
    return {
      'Authorization': 'Bearer $jwtToken',
    };
  }

//Api list
  static String loginApi = '${Constant.baseUrl}login';
  static String getBookings = '${Constant.baseUrl}get_orders';
  static String getServices = '${Constant.baseUrl}get_services';
  static String getServiceCategories = '${Constant.baseUrl}get_all_categories';
  static String getCategories = '${Constant.baseUrl}get_categories';
  static String getPromocodes = '${Constant.baseUrl}get_promocodes';
  static String managePromocode = '${Constant.baseUrl}manage_promocode';
  static String updateBookingStatus = '${Constant.baseUrl}update_order_status';
  static String manageService = '${Constant.baseUrl}manage_service';
  static String deleteService = '${Constant.baseUrl}delete_service';
  static String getServiceRatings = '${Constant.baseUrl}get_service_ratings';
  static String deletePromocode = '${Constant.baseUrl}delete_promocode';
  static String getAvailableSlots = '${Constant.baseUrl}get_available_slots';
  static String getStatistics = '${Constant.baseUrl}get_statistics';
  static String getSettings = '${Constant.baseUrl}get_settings';
  static String getWithdrawalRequest =
      '${Constant.baseUrl}get_withdrawal_request';
  static String sendWithdrawalRequest =
      '${Constant.baseUrl}send_withdrawal_request';
  static String getNotifications = '${Constant.baseUrl}get_notifications';
  static String updateFcm = '${Constant.baseUrl}update_fcm';
  static String deleteUserAccount =
      '${Constant.baseUrl}delete_provider_account';
  static String verifyUser = '${Constant.baseUrl}verify_user';
//AAA
  static String registerProvider = '${Constant.baseUrl}register';

  // static String registerProvider1 = '${Constant.baseUrl1}register';

  static String changePassword = '${Constant.baseUrl}change-password';
  static String createNewPassword = '${Constant.baseUrl}forgot-password';
  static String getTaxes = '${Constant.baseUrl}get_taxes';
  static String getCashCollection = '${Constant.baseUrl}get_cash_collection';
  static String getSettlementHistory =
      '${Constant.baseUrl}get_settlement_history';
  static String createRazorpayOrder =
      "${Constant.baseUrl}razorpay_create_order";
  static String getSubscriptionsList = "${Constant.baseUrl}get_subscription";
  static String addSubscriptionTransaction =
      "${Constant.baseUrl}add_transaction";
  static String getPreviousSubscriptionsHistory =
      "${Constant.baseUrl}get_subscription_history";

  //
  ////////* Place API */////

  static const String _placeApiBaseUrl =
      'https://maps.googleapis.com/maps/api/place/';
  static String placeApiKey = 'key';
  static String placeAPI = '${_placeApiBaseUrl}autocomplete/json';

  static const String input = 'input';
  static const String types = 'types';
  static const String placeid = 'placeid';

  static String placeApiDetails = '${_placeApiBaseUrl}details/json';

//parameters
  static const String mobile = 'mobile';
  static const String mobileNumber = 'mobile_number';
  static const String password = 'password';
  static const String countryCode = 'country_code';
  static const String oldPassword = 'old';
  static const String newPassword = 'new';
  static const String newPasswords = 'new_password';
  static const String limit = 'limit';
  static const String order = 'order';
  static const String sort = 'sort';
  static const String offset = 'offset';
  static const String search = 'search';
  static const String status = 'status';
  static const String serviceId = 'service_id';
  static const String date = 'date';
  static const String promoId = 'promo_id';
  static const String fcmId = 'fcm_id';
  static const String platform = 'platform';

  //
  //register provider
  static const String companyName = 'companyName';
  static const String email = 'email';
  static const String username = 'username';
  static const String companyType = 'type';
  static const String aboutProvider = 'about_provider';
  static const String visitingCharge = 'visiting_charges';
  static const String advanceBookingDays = 'advance_booking_days';
  static const String noOfMember = 'number_of_members';
  static const String currentLocation = 'current_location';
  static const String city = 'city';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String address = 'address';
  static const String taxName = 'tax_name';
  static const String taxNumber = 'tax_number';
  static const String accountNumber = 'account_number';
  static const String accountName = 'account_name';
  static const String bankCode = 'bank_code';
  static const String swiftCode = 'swift_code';
  static const String bankName = 'bank_name';
  static const String confirmPassword = 'password_confirm';
  static const String days = 'days';
  static const String ascending = 'ASC';
  static const String descending = 'DESC';
  static const String subscriptionID = 'subscription_id';
  static const String transactionID = 'transaction_id';
  static const String message = 'message';
  static const String type = 'type';

  ///post method for API calling
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> parameter,
    required bool useAuthToken,
  }) async {
    try {
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(parameter, ListFormat.multiCompatible);
      if (kDebugMode) {
        log.log('API is $url \n para are $parameter ');
      }
      final Response response = await dio.post(
        url,
        data: formData,
        options: useAuthToken
            ? Options(
                contentType: 'multipart/form-data',
                headers: headers(),
              )
            : Options(
                contentType: 'multipart/form-data',
              ),
      );

      if (kDebugMode) {
        print(
          'API is $url \n para are $parameter \n response is ${response.data}',
        );
      }
      return Map.from(response.data);
    } on FormatException catch (e) {
      throw ApiException(e.message);
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      if (e.response?.statusCode == 401) {
        throw ApiException('authenticationFailed');
      } else if (e.response?.statusCode == 500) {
        throw ApiException('internalServerError');
      }
      throw ApiException(
        e.error is SocketException ? 'noInternetFound' : 'somethingWentWrong',
      );
    } on ApiException catch (e) {
      throw ApiException(e.toString());
    } catch (e) {
      throw ApiException('somethingWentWrong');
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      //
      final Dio dio = Dio();

      final Response response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      if (response.data['error'] == true) {
        throw ApiException(response.data['code'].toString());
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException('authenticationFailed');
      } else if (e.response?.statusCode == 500) {
        throw ApiException('internalServerError');
      }
      throw ApiException(
        e.error is SocketException ? 'noInternetFound' : 'somethingWentWrong',
      );
    } on ApiException {
      throw ApiException('somethingWentWrong');
    } catch (e) {
      throw ApiException('somethingWentWrong');
    }
  }
}
