import 'package:edemand_partner/app/generalImports.dart';

class SubscriptionsRepository {
  //
  //this method is used to fetch subscription list
  Future<Map<String, dynamic>> fetchSubscriptionsList() async {
    try {
      final Map<String, dynamic> parameter = {
        Api.limit: Constant.limit,
      };
      //
      final Map<String, dynamic> response = await Api.post(
        url: Api.getSubscriptionsList,
        parameter: parameter,
        useAuthToken: true,
      );
      if (response['error']) {
        return {"data": [], "error": true, "message": e.toString(), "total": "0"};
      }
      return {
        "data": (response['data'] as List)
            .map((e) => SubscriptionInformation.fromJson(Map.from(e)))
            .toList(),
        "error": response['error'] ?? false,
        "total": (response['total'] ?? 0).toString(),
        "message": response['message'] ?? "",
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  //
  //this method is used to fetch provider's previous subscriptions list
  Future<Map<String, dynamic>> fetchPreviousSubscriptionsList({
    required final String offset,
  }) async {
    try {
      //
      final Map<String, dynamic> parameter = {
        Api.offset: offset,
        Api.limit: Constant.limit,
      };
      //
      final Map<String, dynamic> response = await Api.post(
        url: Api.getPreviousSubscriptionsHistory,
        parameter: parameter,
        useAuthToken: true,
      );
      if (response['error']) {
        return {"data": [], "error": true, "message": e.toString(), "total": "0"};
      }
      return {
        "data": (response['data'] as List)
            .map((e) => SubscriptionInformation.fromJson(Map.from(e)))
            .toList(),
        "error": response['error'] ?? false,
        "total": (response['total'] ?? 0).toString(),
        "message": response['message'] ?? "",
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  //
  //this method is used to add subscription transaction
  Future<Map<String, dynamic>> addSubscriptionTransaction({
    required final Map<String, dynamic> parameter,
  }) async {
    try {
      //
      final Map<String, dynamic> response = await Api.post(
        url: Api.addSubscriptionTransaction,
        parameter: parameter,
        useAuthToken: true,
      );
      if (response['error']) {
        return {
          "data": [],
          "error": true,
          "message": response['message'],
        };
      }
      return {
        "paypalPaymentURL": response["data"]["paypal_link"],
        "transactionData": response['data']['transaction'],
        "subscriptionData": response['data']['subscription_information'],
        "error": response['error'] ?? false,
        "message": response['message'] ?? "",
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
