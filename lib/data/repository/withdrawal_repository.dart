/*
import 'package:edemand_partner/app/generalImports.dart';

class WithdrawalRepository {
  //
  Future<DataOutput<WithdrawalModel>> fetchWithdrawalRequests() async {
    Map<String, dynamic> response =
        await Api.post(url: Api.getWithdrawalRequest, parameter: {}, useAuthToken: true);

    List<WithdrawalModel> modelList =
        (response['data'] as List).map((data) => WithdrawalModel.fromJson(data)).toList();

    return DataOutput(total: int.parse(response['total'] ?? "0"), modelList: modelList);
  }

  Future sendWithdrawalRequest({
    required String paymentAddress,
    required String amount,
  }) async {
    Map<String, dynamic> response = await Api.post(
        url: Api.sendWithdrawalRequest,
        parameter: {"payment_address": paymentAddress, "amount": amount, "user_type": "partner"},
        useAuthToken: true);

    return response['balance'];
  }
}
*/
