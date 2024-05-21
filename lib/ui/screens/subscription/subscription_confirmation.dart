import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SubscriptionPaymentConfirmationScreen extends StatelessWidget {
  const SubscriptionPaymentConfirmationScreen({
    required this.isSuccess,
    required this.subscriptionId,
    required this.paymentMethod,
    required this.transactionId,
    super.key,
  });

  final bool isSuccess;
  final String subscriptionId;
  final String paymentMethod;
  final String transactionId;

  static Route route(final RouteSettings routeSettings) {
    //
    final Map arguments = routeSettings.arguments as Map;
    //
    return CupertinoPageRoute(
      builder: (final _) => BlocProvider<AddSubscriptionTransactionCubit>(
        create: (final BuildContext context) =>
            AddSubscriptionTransactionCubit(),
        child: SubscriptionPaymentConfirmationScreen(
          isSuccess: arguments["isSuccess"],
          transactionId: arguments["transactionId"],
          paymentMethod: arguments["paymentMethod"],
          subscriptionId: arguments["subscriptionId"],
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => Container(
        color: Theme.of(context).colorScheme.secondaryColor,
        height: MediaQuery.sizeOf(context).height * 0.6,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(15),
        child: Center(
          child: Column(
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
                    ? "close".translate(context: context)
                    : 'rePayment'.translate(context: context),
                showBorder: false,
                onTap: () {
                  Navigator.pop(context);
                  /*Navigator.of(context).popUntil(
                    (final Route route) => route.isFirst,
                  );*/
                },
              )
            ],
          ),
        ),
      );
}
