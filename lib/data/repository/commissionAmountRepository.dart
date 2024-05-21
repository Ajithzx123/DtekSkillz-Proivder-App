import '../../app/generalImports.dart';

class CommissionAmountRepository {
  //
  //-------------------------------Withdrawal Request Start
  //
  Future<DataOutput<WithdrawalModel>> fetchWithdrawalRequests({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      final Map<String, dynamic> response =
          await Api.post(url: Api.getWithdrawalRequest, parameter: parameter, useAuthToken: true);

      final List<WithdrawalModel> modelList =
          (response['data'] as List).map((data) => WithdrawalModel.fromJson(data)).toList();

      return DataOutput(total: int.parse(response['total'] ?? '0'), modelList: modelList);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future sendWithdrawalRequest({
    required String paymentAddress,
    required String amount,
  }) async {
    try {
      final Map<String, dynamic> response = await Api.post(
        url: Api.sendWithdrawalRequest,
        parameter: {'payment_address': paymentAddress, 'amount': amount, 'user_type': 'partner'},
        useAuthToken: true,
      );

      return response['balance'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

//
//-------------------------------Withdrawal Request End
//
//-------------------------------Cash collection Start
//
  Future<DataOutput<CashCollectionModel>> fetchCashCollectionHistory({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      final Map<String, dynamic> response =
          await Api.post(url: Api.getCashCollection, parameter: parameter, useAuthToken: true);

      final List<CashCollectionModel> cashCollectionData =
          (response['data'] as List).map((data) => CashCollectionModel.fromJson(data)).toList();

      return DataOutput(
        total: int.parse(response['total'] ?? '0'),
        modelList: cashCollectionData,
        extraData: ExtraData(
          data: {'totalPayableCommission': response['payable_commision'].toString()},
        ),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

//
//-------------------------------Cash collection end
//-------------------------------Settlement  Start
//
  Future<DataOutput<SettlementModel>> fetchSettlementHistory({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      final Map<String, dynamic> response =
          await Api.post(url: Api.getSettlementHistory, parameter: parameter, useAuthToken: true);

      final List<SettlementModel> settlementData =
          (response['data'] as List).map((data) => SettlementModel.fromJson(data)).toList();

      return DataOutput(
          total: int.parse((response['total'] ?? '0').toString()), modelList: settlementData);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
//
}
