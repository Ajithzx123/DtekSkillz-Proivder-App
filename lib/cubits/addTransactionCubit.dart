// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../app/generalImports.dart';

abstract class AddSubscriptionTransactionState {}

class AddSubscriptionTransactionInitial extends AddSubscriptionTransactionState {}

class AddSubscriptionTransactionInProgress extends AddSubscriptionTransactionState {
  final String subscriptionId;

  AddSubscriptionTransactionInProgress({required this.subscriptionId});
}

class AddSubscriptionTransactionSuccess extends AddSubscriptionTransactionState {
  final String transactionId;
  final String paymentMethodType;
  final String paypalPaymentURL;
  final String subscriptionAmount;
  final String subscriptionId;
  final String razorpayOrderId;
  final String subscriptionStatus;
  final SubscriptionInformation subscriptionInformation;

  AddSubscriptionTransactionSuccess({
    required this.subscriptionStatus,
    required this.paypalPaymentURL,
    required this.subscriptionInformation,
    required this.razorpayOrderId,
    required this.transactionId,
    required this.paymentMethodType,
    required this.subscriptionAmount,
    required this.subscriptionId,
  });
}

class AddSubscriptionTransactionFailure extends AddSubscriptionTransactionState {
  final String errorMessage;

  AddSubscriptionTransactionFailure(this.errorMessage);
}

class AddSubscriptionTransactionCubit extends Cubit<AddSubscriptionTransactionState> {
  AddSubscriptionTransactionCubit() : super(AddSubscriptionTransactionInitial());

  //
  final SubscriptionsRepository _subscriptionsRepository = SubscriptionsRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();

  //
  Future<void> addSubscriptionTransaction({
    required final String subscriptionId,
    final String? transactionId,
    required final String message,
    required final String status,
    required final String paymentMethodType,
    required bool needToCreateRazorpayOrderID,
  }) async {
    try {
      //
      emit(AddSubscriptionTransactionInProgress(subscriptionId: subscriptionId));
      //
      String razorpayOrderId = "";
      //
      final Map<String, dynamic> transactionData =
          await _subscriptionsRepository.addSubscriptionTransaction(
        parameter: {
          Api.subscriptionID: subscriptionId,
          Api.status: status,
          Api.transactionID: transactionId,
          Api.message: message,
          Api.type: paymentMethodType
        },
      );

      if (transactionData["error"]) {
        throw ApiException(transactionData['message']);
      }
      //
      if (paymentMethodType == "Razorpay" && needToCreateRazorpayOrderID) {
        razorpayOrderId =
            await _settingsRepository.createRazorpayOrderId(subscriptionID: subscriptionId);
      }

      emit(
        AddSubscriptionTransactionSuccess(
          paypalPaymentURL: transactionData["paypalPaymentURL"] ?? "",
          subscriptionStatus: status.toString(),
          subscriptionInformation:
              SubscriptionInformation.fromJson(Map.from(transactionData["subscriptionData"] ?? {})),
          subscriptionId: subscriptionId.toString(),
          razorpayOrderId: razorpayOrderId.toString(),
          subscriptionAmount: transactionData['transactionData']['amount'].toString(),
          paymentMethodType: paymentMethodType.toString(),
          transactionId: transactionData['transactionData']['id'] ?? "0",
        ),
      );
    } catch (e,st) {
      print("error is ${e.toString()}n ${st.toString()}");
      emit(AddSubscriptionTransactionFailure(e.toString()));
    }
  }

  Map<String, dynamic> getTransactionDetails() {
    if (state is AddSubscriptionTransactionSuccess) {
      return {
        "subscriptionAmount": (state as AddSubscriptionTransactionSuccess).subscriptionAmount,
        "transactionId": (state as AddSubscriptionTransactionSuccess).transactionId,
        "subscriptionId": (state as AddSubscriptionTransactionSuccess).subscriptionId,
        "paymentMethodType": (state as AddSubscriptionTransactionSuccess).paymentMethodType,
      };
    }
    return {
      "subscriptionAmount": "0",
      "transactionId": "0",
      "subscriptionId": "0",
      "paymentMethodType": "",
    };
  }
}
