import '../../app/generalImports.dart';

class SettingsRepository {
  //
  Future getSystemSettings({required bool isAnonymous}) async {
    try {
      //

      final Map<String, dynamic> response = await Api.post(
        url: Api.getSettings,
        parameter: {},
        useAuthToken: isAnonymous ? false : true,
      );
      return response['data'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future updateFCM({required final String fcmId,required final String platform}) async {
    await Api.post(
        url: Api.updateFcm,
        parameter: {
          Api.fcmId: fcmId,
          Api.platform: platform,
        },
        useAuthToken: true);
  }

  //
  ///This method is used to create razorpay order Id
  Future<String> createRazorpayOrderId({required final String subscriptionID}) async {
    try {
      final Map<String, dynamic> parameters = {Api.subscriptionID: subscriptionID};
      final result =
          await Api.post(parameter: parameters, url: Api.createRazorpayOrder, useAuthToken: true);

      return result['data']['id'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
