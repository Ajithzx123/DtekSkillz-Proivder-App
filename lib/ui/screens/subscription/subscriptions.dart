import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/cubits/fetchPreviousSubscriptionsCubit.dart';

import 'package:edemand_partner/ui/screens/subscription/widgets/subscriptionDetailsContainer.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SubscriptionsScreen extends StatefulWidget {
  //s
  final String from;

  const SubscriptionsScreen({
    super.key,
    required this.from,
  });

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) {
        final Map<String, dynamic> arguments =
            routeSettings.arguments as Map<String, dynamic>;
        //
        return MultiBlocProvider(
          providers: [
            BlocProvider<FetchSubscriptionsCubit>(
              create: (context) => FetchSubscriptionsCubit(),
            ),
            BlocProvider<AddSubscriptionTransactionCubit>(
              create: (context) => AddSubscriptionTransactionCubit(),
            ),
          ],
          child: SubscriptionsScreen(
            from: arguments["from"],
          ),
        );
      },
    );
  }

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  //
  PaymentGatewaysSettings? paymentGatewaySetting;

  //------------------------ PayStack Payment Gateway Start ----------------------------------
  PaystackPlugin payStackPaymentGateway = PaystackPlugin();

  //initialize PayStack
  Future<void> initializePayStack() async {
    await payStackPaymentGateway.initialize(
        publicKey: paymentGatewaySetting!.paystackKey!);
  }

  //Using package flutter_paystack
  Future<void> openPaystackPaymentGateway({
    required final double subscriptionAmount,
    required final String emailId,
    required final String transactionId,
  }) async {
    final charge = Charge()
      ..amount = (subscriptionAmount * 100).toInt()
      ..reference = _getReference()
      ..email = emailId
      ..currency = paymentGatewaySetting!.paystackCurrency
      ..putMetaData('transaction_id', transactionId);

    final CheckoutResponse response = await payStackPaymentGateway.checkout(
      context,
      logo: UiUtils.setSVGImage("splashlogo", width: 50, height: 50),
      method: CheckoutMethod.card,
      // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.status) {
      navigateToSubscriptionConfirmation(
        isSuccess: true,
      );
    } else {
      navigateToSubscriptionConfirmation(
        isSuccess: false,
      );
    }
  }

  //
  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  //----------------------------------- Paystack Payment Gateway end ----------------------------

  //----------------------------------- Razorpay Payment Gateway Start ----------------------------
  final Razorpay _razorpay = Razorpay();

  Future<void> initializeRazorpay() async {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);
  }

  void _handleRazorPayPaymentSuccess(final PaymentSuccessResponse response) {
    _razorpay.clear();
    navigateToSubscriptionConfirmation(isSuccess: true);
  }

  void _handleRazorPayPaymentError(final PaymentFailureResponse response) {
    _razorpay.clear();

    navigateToSubscriptionConfirmation(isSuccess: false);
  }

  void _handleRazorPayExternalWallet(final ExternalWalletResponse response) {
    _razorpay.clear();
  }

  Future<void> openRazorPayGateway({
    required final double subscriptionAmount,
    required final String razorpayOrderId,
    required final String subscriptionId,
    required final String transactionId,
  }) async {
    final options = <String, Object?>{
      'key':
          paymentGatewaySetting!.razorpayKey, //this should be come from server
      'amount': (subscriptionAmount * 100).toInt(),
      'name': Constant.appName,
      'description':
          'razorpaySubscriptionPlanDescription'.translate(context: context),
      'currency': paymentGatewaySetting!.razorpayCurrency,
      'notes': {'transaction_id': transactionId},
      'order_id': razorpayOrderId,
      'prefill': {
        'contact':
            context.read<ProviderDetailsCubit>().providerDetails.user?.phone ??
                "",
        'email':
            context.read<ProviderDetailsCubit>().providerDetails.user?.email ??
                ""
      }
    };

    _razorpay.open(options);
  }

  //----------------------------------- Razorpay Payment Gateway End ----------------------------

  //----------------------------------- Stripe Payment Gateway Start ----------------------------
  Future<void> openStripePaymentGateway({
    required final double subscriptionAmount,
    required final String transactionId,
  }) async {
    try {
      StripeService.secret = paymentGatewaySetting!.stripeSecretKey;
      StripeService.init(
        paymentGatewaySetting!.stripePublishableKey,
        paymentGatewaySetting!.stripeMode,
      );

      final response = await StripeService.payWithPaymentSheet(
        amount: (subscriptionAmount * 100).toInt(),
        currency: paymentGatewaySetting!.stripeCurrency,
        isTestEnvironment: paymentGatewaySetting!.stripeMode == "test",
        transactionID: transactionId,
        from: 'subscription',
      );

      if (response.status == 'succeeded') {
        navigateToSubscriptionConfirmation(
          isSuccess: true,
        );
      } else {
        navigateToSubscriptionConfirmation(isSuccess: false);
      }
    } catch (_) {}
  }

  //----------------------------------- Stripe Payment Gateway End ----------------------------

  @override
  void initState() {
    super.initState();
    fetchSubscriptionDetails();
    getPaymentGatewaySetting();
  }

  @override
  void dispose() {
    _razorpay.clear();

    payStackPaymentGateway.dispose();
    super.dispose();
  }

  void fetchSubscriptionDetails() {
    Future.delayed(
      Duration.zero,
      () {
        context.read<FetchSubscriptionsCubit>().fetchSubscriptions();
        context
            .read<FetchPreviousSubscriptionsCubit>()
            .fetchPreviousSubscriptions();
      },
    );
  }

  void fetchProviderSubscriptionDetailsFromSettingsAPI() {
    Future.delayed(
      Duration.zero,
      () {
        context
            .read<FetchSystemSettingsCubit>()
            .getSettings(isAnonymous: false);
      },
    );
  }

  void getPaymentGatewaySetting() {
    paymentGatewaySetting =
        context.read<FetchSystemSettingsCubit>().getPaymentMethodSettings();
  }

  Future<dynamic> showSubscriptionMessageDialog({
    required final isSuccess,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          title: Text(
            (isSuccess ? "paymentSuccess" : "paymentFailed")
                .translate(context: context),
            style: TextStyle(
                color: isSuccess ? AppColors.greenColor : AppColors.redColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                isSuccess
                    ? "assets/animation/success.json"
                    : "assets/animation/fail.json",
                height: 150,
                width: 150,
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                isSuccess
                    ? "subscriptionSuccess".translate(context: context)
                    : "subscriptionFailure".translate(context: context),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 25,
              ),
              CustomRoundedButton(
                widthPercentage: 0.9,
                backgroundColor: Theme.of(context).colorScheme.accentColor,
                buttonTitle: isSuccess
                    ? "goToHome".translate(context: context)
                    : 'okay'.translate(context: context),
                showBorder: false,
                onTap: () {
                  if (isSuccess) {
                    if (widget.from == "drawer") {
                      Navigator.of(context)
                          .popUntil((Route route) => route.isFirst);
                    } else if (widget.from == "login" ||
                        widget.from == "splash") {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, Routes.main);
                    }
                    return;
                  }
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  void navigateToSubscriptionConfirmation({
    required final bool isSuccess,
  }) {
    final Map<String, dynamic> transactionData =
        context.read<AddSubscriptionTransactionCubit>().getTransactionDetails();
    //
    if (!isSuccess) {
      context
          .read<AddSubscriptionTransactionCubit>()
          .addSubscriptionTransaction(
            needToCreateRazorpayOrderID: false,
            paymentMethodType: transactionData["paymentMethodType"],
            status: "failed",
            subscriptionId: transactionData["subscriptionId"],
            message: "Payment Failed",
            transactionId: transactionData["transactionId"],
          );
    } else {
      context
          .read<AddSubscriptionTransactionCubit>()
          .addSubscriptionTransaction(
            needToCreateRazorpayOrderID: false,
            message: "Payment successful",
            status: "success",
            paymentMethodType: transactionData["paymentMethodType"],
            subscriptionId: transactionData["subscriptionId"],
            transactionId: transactionData["transactionId"],
          );
    }
    showSubscriptionMessageDialog(isSuccess: isSuccess);
  }

  Widget setSubscriptionPlanDetailsPoint({
    required final String title,
  }) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.greenColor,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: Theme.of(context).colorScheme.blackColor),
          ),
        )
      ],
    );
  }

  void onBuyButtonPressed(
      {required final bool isLoading,
      required final String subscriptionId,
      required final String price}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogs.showConfirmDialoge(
          context: context,
          title: 'areYouSure'.translate(context: context),
          cancleButtonName: 'cancel'.translate(context: context),
          confirmButtonName: 'buy'.translate(context: context),
          confirmButtonColor: Theme.of(context).colorScheme.accentColor,
          description: 'buySubscriptionDescription'.translate(context: context),
          onConfirmed: () async {
            Navigator.pop(context, {"isConfirm": true});
          },
          onCancled: () {},
        );
      },
    ).then((value) {
      if (value == null) {
        return;
      }
      if (value["isConfirm"]) {
        if (price == "0") {
          context
              .read<AddSubscriptionTransactionCubit>()
              .addSubscriptionTransaction(
                needToCreateRazorpayOrderID: false,
                subscriptionId: subscriptionId,
                message: "subscription successful",
                status: "active",
                paymentMethodType: "test",
              );
          return;
        }
        if (paymentGatewaySetting!.stripeStatus == "enable") {
          //
          context
              .read<AddSubscriptionTransactionCubit>()
              .addSubscriptionTransaction(
                needToCreateRazorpayOrderID: false,
                subscriptionId: subscriptionId,
                message: "subscription successful",
                status: "Pending",
                paymentMethodType: "Stripe",
              );
          //
        } else if (paymentGatewaySetting!.razorpayApiStatus == "enable") {
          //
          context
              .read<AddSubscriptionTransactionCubit>()
              .addSubscriptionTransaction(
                needToCreateRazorpayOrderID: true,
                subscriptionId: subscriptionId,
                message: "subscription successful",
                status: "Pending",
                paymentMethodType: "Razorpay",
              );
          //
        } else if (paymentGatewaySetting!.paystackStatus == "enable") {
          //
          context
              .read<AddSubscriptionTransactionCubit>()
              .addSubscriptionTransaction(
                needToCreateRazorpayOrderID: false,
                subscriptionId: subscriptionId,
                message: "subscription successful",
                status: "Pending",
                paymentMethodType: "Paystack",
              );
        } else if (paymentGatewaySetting!.paypalStatus == "enable") {
          //
          context
              .read<AddSubscriptionTransactionCubit>()
              .addSubscriptionTransaction(
                needToCreateRazorpayOrderID: false,
                subscriptionId: subscriptionId,
                message: "subscription successful",
                status: "Pending",
                paymentMethodType: "paypal",
              );

          //
        } else {
          UiUtils.showMessage(
            context,
            "onlinePaymentNotAvailableNow".translate(context: context),
            MessageType.warning,
          );
        }
      }
      return;
    });
  }

  Widget getCurrentlyActivePlanDetails({
    required SubscriptionInformation activeSubscriptionInformation,
  }) {
    //
    print("subscription is $activeSubscriptionInformation");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: getTitle(
              title: "currentSubscription".translate(context: context)),
        ),
        SubscriptionDetailsContainer(
          onBuyButtonPressed: () {
            onBuyButtonPressed(
              price: activeSubscriptionInformation.discountPrice != "0"
                  ? activeSubscriptionInformation.discountPriceWithTax ?? "0"
                  : activeSubscriptionInformation.priceWithTax ?? "0",
              subscriptionId: activeSubscriptionInformation.id ?? "0",
              isLoading: false,
            );
          },
          subscriptionTaxPercentage:
              activeSubscriptionInformation.taxPercenrage ?? "0.00",
          isPreviousSubscription: false,
          isAvailableForPurchase: false,
          showLoading: false,
          isActiveSubscription: true,
          needToShowPaymentStatus: true,
          subscriptionPaymentStatus:
              activeSubscriptionInformation.isPayment ?? "0",
          //0-pending 1-success 2-failed
          subscriptionId: activeSubscriptionInformation.id ?? "0",
          subscriptionTitle: activeSubscriptionInformation.name ?? "",
          subscriptionDuration: activeSubscriptionInformation.duration ?? "",
          subscriptionExpiryDate:
              activeSubscriptionInformation.expiryDate ?? "",
          subscriptionDescription:
              activeSubscriptionInformation.description ?? "",
          subscriptionPurchasedDate:
              activeSubscriptionInformation.purchaseDate ?? "",
          subscriptionMaxOrderLimit:
              activeSubscriptionInformation.maxOrderLimit ?? "",
          isSubscriptionHasCommission:
              activeSubscriptionInformation.isCommision == "yes",
          subscriptionCommissionThreshold:
              activeSubscriptionInformation.commissionThreshold ?? "",
          subscriptionCommissionPercentage:
              activeSubscriptionInformation.commissionPercentage ?? "",
          subscriptionDiscountPrice:
              activeSubscriptionInformation.discountPrice ?? "0",
          subscriptionPrice: activeSubscriptionInformation.price ?? "0",
          subscriptionDiscountPriceWithTax:
              activeSubscriptionInformation.discountPriceWithTax ?? "0",
          subscriptionPriceWithTax:
              activeSubscriptionInformation.priceWithTax ?? "0",
        ),
      ],
    );
  }

  Widget getTitle({required String title}) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.blackColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }

  Widget subscriptionsDetailsContainer() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            if (context
                        .watch<ProviderDetailsCubit>()
                        .providerDetails
                        .subscriptionInformation
                        ?.isSubscriptionActive ==
                    "active" ||
                context
                        .watch<ProviderDetailsCubit>()
                        .providerDetails
                        .subscriptionInformation
                        ?.isSubscriptionActive ==
                    "pending")
              BlocBuilder<ProviderDetailsCubit, ProviderDetailsState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: getCurrentlyActivePlanDetails(
                      activeSubscriptionInformation:
                          state.providerDetails.subscriptionInformation ??
                              SubscriptionInformation(),
                    ),
                  );
                },
              ),
            BlocBuilder<FetchPreviousSubscriptionsCubit,
                FetchPreviousSubscriptionsState>(
              builder: (context, state) {
                if (state is FetchPreviousSubscriptionsInProgress) {
                  return ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                    height: 300,
                    width: MediaQuery.sizeOf(context).width,
                  ));
                }
                if (state is FetchPreviousSubscriptionsSuccess) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            getTitle(
                                title: "previousSubscriptions"
                                    .translate(context: context)),
                            const Spacer(),
                            InkWell(
                              child: Text(
                                "viewAll".translate(context: context),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.accentColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, Routes.previousSubscriptions);
                              },
                            )
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              state.subscriptionsData.length > 5
                                  ? 5
                                  : state.subscriptionsData.length, (index) {
                            //
                            final SubscriptionInformation subscriptionDetails =
                                state.subscriptionsData[index];
                            //
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: SubscriptionDetailsContainer(
                                onBuyButtonPressed: () {
                                  onBuyButtonPressed(
                                    price: subscriptionDetails.discountPrice !=
                                            "0"
                                        ? subscriptionDetails
                                                .discountPriceWithTax ??
                                            "0"
                                        : subscriptionDetails.priceWithTax ??
                                            "0",
                                    isLoading: false,
                                    subscriptionId:
                                        subscriptionDetails.id ?? "0",
                                  );
                                },
                                isPreviousSubscription: true,
                                subscriptionExpiryDate:
                                    subscriptionDetails.expiryDate ?? "",
                                subscriptionPurchasedDate:
                                    subscriptionDetails.purchaseDate ?? "",
                                isAvailableForPurchase: false,
                                subscriptionPaymentStatus:
                                    subscriptionDetails.isPayment ?? "0",
                                isActiveSubscription: false,
                                needToShowPaymentStatus: true,
                                subscriptionTitle:
                                    subscriptionDetails.name ?? "",
                                subscriptionDescription:
                                    subscriptionDetails.description ?? "",
                                subscriptionPrice:
                                    subscriptionDetails.price ?? "0",
                                subscriptionDiscountPrice:
                                    subscriptionDetails.discountPrice ?? "0",
                                subscriptionDiscountPriceWithTax:
                                    subscriptionDetails.discountPriceWithTax ??
                                        "0",
                                subscriptionPriceWithTax:
                                    subscriptionDetails.priceWithTax ?? "0",
                                showLoading: false,
                                subscriptionId: subscriptionDetails.id ?? "0",
                                isSubscriptionHasCommission:
                                    subscriptionDetails.isCommision == "yes",
                                subscriptionCommissionPercentage:
                                    subscriptionDetails.commissionPercentage ??
                                        "",
                                subscriptionCommissionThreshold:
                                    subscriptionDetails.commissionThreshold ??
                                        "",
                                subscriptionDuration:
                                    subscriptionDetails.duration ?? "",
                                subscriptionMaxOrderLimit:
                                    subscriptionDetails.maxOrderLimit ?? "",
                                subscriptionTaxPercentage:
                                    subscriptionDetails.taxPercenrage ?? "0.00",
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                }
                return Container();
              },
            ),
            BlocConsumer<AddSubscriptionTransactionCubit,
                AddSubscriptionTransactionState>(
              listener: (context, state) async {
                if (state is AddSubscriptionTransactionFailure) {
                  UiUtils.showMessage(
                    context,
                    state.errorMessage.translate(context: context),
                    MessageType.error,
                  );
                }
                if (state is AddSubscriptionTransactionSuccess) {
                  //
                  context.read<ProviderDetailsCubit>().updateProviderDetails(
                        subscriptionInformation: state.subscriptionInformation,
                      );
                  //
                  if (state.subscriptionStatus == "success" ||
                      state.subscriptionStatus == "failed") {
                    return;
                  }
                  if (state.paymentMethodType == "Stripe") {
                    //
                    openStripePaymentGateway(
                      transactionId: state.transactionId.toString(),
                      subscriptionAmount:
                          double.parse(state.subscriptionAmount),
                    );
                    //
                  } else if (state.paymentMethodType == "Razorpay") {
                    //
                    await initializeRazorpay();
                    //
                    final Map<String, dynamic> transactionDetails = context
                        .read<AddSubscriptionTransactionCubit>()
                        .getTransactionDetails(); //
                    openRazorPayGateway(
                      subscriptionAmount: double.parse(
                          transactionDetails["subscriptionAmount"]),
                      razorpayOrderId: state.razorpayOrderId,
                      subscriptionId: transactionDetails["subscriptionId"],
                      transactionId: transactionDetails["transactionId"],
                    );
                    //
                  } else if (state.paymentMethodType == "Paystack") {
                    //
                    await initializePayStack();
                    openPaystackPaymentGateway(
                      subscriptionAmount:
                          double.parse(state.subscriptionAmount),
                      emailId: context
                              .read<ProviderDetailsCubit>()
                              .providerDetails
                              .user
                              ?.email ??
                          "test@gmail.com",
                      transactionId: state.transactionId.toString(),
                    );
                    //
                  } else if (state.paymentMethodType == "test") {
                    showSubscriptionMessageDialog(isSuccess: true);
                  } else if (state.paymentMethodType == "paypal") {
                    //
                    Navigator.pushNamed(
                      context,
                      Routes.paypalPaymentScreen,
                      arguments: {'paymentURL': state.paypalPaymentURL},
                    ).then((final Object? value) {
                      final parameter = value as Map;
                      if (parameter['paymentStatus'] == 'Completed') {
                        //
                        navigateToSubscriptionConfirmation(isSuccess: true);
                        //
                      } else if (parameter['paymentStatus'] == 'Failed') {
                        navigateToSubscriptionConfirmation(isSuccess: false);
                      }
                    });
                    //
                  } else {
                    UiUtils.showMessage(
                      context,
                      "onlinePaymentMethodNotAvailable"
                          .translate(context: context),
                      MessageType.error,
                    );
                  }
                }
              },
              builder: (context, state) {
                bool showLoading = false;
                String onGoingPaymentSubscriptionId = "-1";
                //
                if (state is AddSubscriptionTransactionInProgress) {
                  showLoading = true;
                  onGoingPaymentSubscriptionId = state.subscriptionId;
                } else if (state is AddSubscriptionTransactionSuccess ||
                    state is AddSubscriptionTransactionFailure) {
                  showLoading = false;
                }
                return context
                            .watch<ProviderDetailsCubit>()
                            .providerDetails
                            .subscriptionInformation
                            ?.isSubscriptionActive ==
                        "deactive"
                    ? BlocBuilder<FetchSubscriptionsCubit,
                        FetchSubscriptionsState>(
                        builder: (context, state) {
                          if (state is FetchSubscriptionsFailure) {
                            return Center(
                              child: ErrorContainer(
                                errorMessage: state.errorMessage
                                    .translate(context: context),
                                onTapRetry: () {
                                  context
                                      .read<FetchSubscriptionsCubit>()
                                      .fetchSubscriptions();
                                },
                              ),
                            );
                          } else if (state is FetchSubscriptionsSuccess) {
                            //
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: getTitle(
                                      title: "subscriptionPlans"
                                          .translate(context: context),
                                    ),
                                  ),
                                  Column(
                                    children: List.generate(
                                        state.subscriptionsData.length +
                                            (state.isLoadingMoreSubscriptions
                                                ? 1
                                                : 0), (index) {
                                      if (index >=
                                          state.subscriptionsData.length) {
                                        return const CircularProgressIndicator();
                                      }
                                      //
                                      final SubscriptionInformation
                                          subscriptionDetails =
                                          state.subscriptionsData[index];
                                      //
                                      return SubscriptionDetailsContainer(
                                        onBuyButtonPressed: () {
                                          onBuyButtonPressed(
                                            price: subscriptionDetails
                                                        .discountPrice !=
                                                    "0"
                                                ? subscriptionDetails
                                                        .discountPriceWithTax ??
                                                    "0"
                                                : subscriptionDetails
                                                        .priceWithTax ??
                                                    "0",
                                            isLoading:
                                                onGoingPaymentSubscriptionId ==
                                                        subscriptionDetails.id
                                                    ? showLoading
                                                    : false,
                                            subscriptionId:
                                                subscriptionDetails.id ?? "0",
                                          );
                                        },
                                        isPreviousSubscription: false,
                                        subscriptionExpiryDate:
                                            subscriptionDetails.expiryDate ??
                                                "",
                                        subscriptionPurchasedDate:
                                            subscriptionDetails.purchaseDate ??
                                                "",
                                        isAvailableForPurchase: context
                                                .read<ProviderDetailsCubit>()
                                                .providerDetails
                                                .subscriptionInformation
                                                ?.isSubscriptionActive ==
                                            "deactive",
                                        subscriptionPaymentStatus:
                                            subscriptionDetails.isPayment ??
                                                "0",
                                        //0-pending 1-success 2-failed
                                        isActiveSubscription: false,
                                        needToShowPaymentStatus: false,
                                        subscriptionTitle:
                                            subscriptionDetails.name ?? "",
                                        subscriptionDescription:
                                            subscriptionDetails.description ??
                                                "",
                                        subscriptionPrice:
                                            subscriptionDetails.price ?? "0",
                                        subscriptionDiscountPrice:
                                            subscriptionDetails.discountPrice ??
                                                "0",
                                        subscriptionDiscountPriceWithTax:
                                            subscriptionDetails
                                                    .discountPriceWithTax ??
                                                "0",
                                        subscriptionPriceWithTax:
                                            subscriptionDetails.priceWithTax ??
                                                "0",
                                        showLoading:
                                            onGoingPaymentSubscriptionId ==
                                                    subscriptionDetails.id
                                                ? showLoading
                                                : false,
                                        subscriptionId:
                                            subscriptionDetails.id ?? "0",
                                        isSubscriptionHasCommission:
                                            subscriptionDetails.isCommision ==
                                                "yes",
                                        subscriptionCommissionPercentage:
                                            subscriptionDetails
                                                    .commissionPercentage ??
                                                "",
                                        subscriptionCommissionThreshold:
                                            subscriptionDetails
                                                    .commissionThreshold ??
                                                "",
                                        subscriptionDuration:
                                            subscriptionDetails.duration ?? "",
                                        subscriptionMaxOrderLimit:
                                            subscriptionDetails.maxOrderLimit ??
                                                "",
                                        subscriptionTaxPercentage:
                                            subscriptionDetails.taxPercenrage ??
                                                "0.00",
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Center(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: List.generate(
                                  7,
                                  (index) => ShimmerLoadingContainer(
                                    child: CustomShimmerContainer(
                                      height: 150,
                                      width: MediaQuery.sizeOf(context).width,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      borderRadius: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  //
  @override
  Widget build(BuildContext context) {
    final bool isSubscriptionActive = context
            .watch<ProviderDetailsCubit>()
            .providerDetails
            .subscriptionInformation
            ?.isSubscriptionActive ==
        "active";
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: WillPopScope(
        onWillPop: () {
          if (widget.from == "login" || widget.from == "splash") {
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryColor,
            appBar: AppBar(
              elevation: 1,
              centerTitle: true,
              leading: widget.from == "login" || widget.from == "splash"
                  ? null
                  : UiUtils.setBackArrow(context),
              backgroundColor: Theme.of(context).colorScheme.secondaryColor,
              title: CustomText(
                titleText: 'subscriptions'.translate(context: context),
                fontColor: Theme.of(context).colorScheme.blackColor,
                fontWeight: FontWeight.bold,
              ),
              actions: [
                if (context
                            .watch<ProviderDetailsCubit>()
                            .providerDetails
                            .subscriptionInformation
                            ?.isSubscriptionActive ==
                        "active" &&
                    (widget.from == "login" || widget.from == "splash"))
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(Routes.main);
                      },
                      child: Icon(
                        Icons.home_outlined,
                        color: Theme.of(context).colorScheme.blackColor,
                        size: 30,
                      ),
                    ),
                  )
              ],
            ),
            body: BlocListener<FetchSystemSettingsCubit,
                FetchSystemSettingsState>(
              listener: (context, state) {
                if (state is FetchSystemSettingsSuccess) {
                  context.read<ProviderDetailsCubit>().updateProviderDetails(
                      subscriptionInformation: state.subscriptionInformation);
                }
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  fetchSubscriptionDetails();
                  fetchProviderSubscriptionDetailsFromSettingsAPI();
                },
                child: subscriptionsDetailsContainer(),
              ),
            )),
      ),
    );
  }
}
