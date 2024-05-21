import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/ui/widgets/customReadMoreTextContainer.dart';
import 'package:flutter/material.dart';

class SubscriptionDetailsContainer extends StatelessWidget {
  final String subscriptionTitle;
  final String subscriptionPrice;
  final String subscriptionDiscountPrice;
  final String subscriptionPriceWithTax;
  final String subscriptionDiscountPriceWithTax;
  final String subscriptionDescription;
  final String subscriptionPaymentStatus;
  final String subscriptionMaxOrderLimit;
  final String subscriptionDuration;
  final String subscriptionCommissionPercentage;
  final String subscriptionCommissionThreshold;
  final String subscriptionId;
  final String? subscriptionPurchasedDate;
  final String? subscriptionExpiryDate;
  final String subscriptionTaxPercentage;
  final bool? showLoading;
  final bool isActiveSubscription;
  final bool isAvailableForPurchase;
  final bool isPreviousSubscription;
  final bool isSubscriptionHasCommission;
  final bool needToShowPaymentStatus;

  final Function onBuyButtonPressed;

  const SubscriptionDetailsContainer({
    super.key,
    required this.subscriptionTitle,
    required this.subscriptionPrice,
    required this.subscriptionDiscountPrice,
    required this.subscriptionDescription,
    required this.subscriptionPaymentStatus,
    required this.onBuyButtonPressed,
    required this.isActiveSubscription,
    required this.isAvailableForPurchase,
    required this.isPreviousSubscription,
    required this.subscriptionMaxOrderLimit,
    required this.subscriptionDuration,
    required this.isSubscriptionHasCommission,
    required this.subscriptionCommissionPercentage,
    required this.subscriptionCommissionThreshold,
    required this.subscriptionId,
    this.subscriptionPurchasedDate,
    this.subscriptionExpiryDate,
    this.showLoading,
    required this.needToShowPaymentStatus,
    required this.subscriptionTaxPercentage,
    required this.subscriptionPriceWithTax,
    required this.subscriptionDiscountPriceWithTax,
  });

  Widget getPaymentStatusContainer(
      {required String paymentStatus, required BuildContext context}) {
    return Row(
      children: [
        Icon(
          paymentStatus == "0"
              ? Icons.pending
              : paymentStatus == "1"
                  ? Icons.done
                  : Icons.close,
          size: 16,
          color: paymentStatus == "0"
              ? AppColors.starRatingColor
              : paymentStatus == "1"
                  ? AppColors.greenColor
                  : AppColors.redColor,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          paymentStatus == "0"
              ? "paymentPending".translate(context: context)
              : paymentStatus == "1"
                  ? "paymentSuccess".translate(context: context)
                  : "paymentFailed".translate(context: context),
          style: TextStyle(
            color: paymentStatus == "0"
                ? AppColors.starRatingColor
                : paymentStatus == "1"
                    ? AppColors.greenColor
                    : AppColors.redColor,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ],
    );
  }

  Widget getTitle({required String title, required BuildContext context}) {
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

  Widget setSubscriptionPlanDetailsPoint({
    required final String title,
    required final BuildContext context,
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
            style: TextStyle(
                color: Theme.of(context).colorScheme.blackColor, fontSize: 12),
          ),
        )
      ],
    );
  }

  Widget buyButton({
    required final bool isLoading,
    required final String subscriptionId,
    required BuildContext context,
    required Function onBuyButtonPressed,
  }) {
    return CustomRoundedButton(
      widthPercentage: 0.9,
      height: 30,
      textSize: 14,
      radius: 5,
      backgroundColor: Theme.of(context).colorScheme.accentColor,
      buttonTitle: "buyPlan".translate(context: context),
      showBorder: false,
      onTap: () {
        onBuyButtonPressed.call();
      },
      child: isLoading
          ? Container(
              height: 30,
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: FittedBox(
                child: CircularProgressIndicator(
                  color: AppColors.whiteColors,
                  strokeWidth: 2,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needToShowPaymentStatus) ...[
              getPaymentStatusContainer(
                paymentStatus: subscriptionPaymentStatus.capitalize(),
                context: context,
              ),
              const SizedBox(
                height: 5,
              ),
            ],

            getTitle(title: subscriptionTitle, context: context),
            const SizedBox(
              height: 5,
            ),

            Row(
              children: [
                Text(
                  UiUtils.getPriceFormat(
                    context,
                    double.parse(
                      subscriptionDiscountPrice != "0"
                          ? subscriptionDiscountPriceWithTax
                          : subscriptionPriceWithTax,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.accentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                if (subscriptionDiscountPrice != "0") ...[
                  const SizedBox(width: 3),
                  Text(
                    UiUtils.getPriceFormat(
                      context,
                      double.parse(
                        subscriptionPriceWithTax,
                      ),
                    ),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightGreyColor,
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ],
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            if (subscriptionTaxPercentage != "0")
              setSubscriptionPlanDetailsPoint(
                context: context,
                title:
                    "$subscriptionTaxPercentage% ${"taxIncludedInPrice".translate(context: context)}",
              ),
            setSubscriptionPlanDetailsPoint(
              context: context,
              title: subscriptionMaxOrderLimit != "" &&
                      subscriptionMaxOrderLimit != "0"
                  ? "${"enjoyGenerousOrderLimitOf".translate(context: context)} $subscriptionMaxOrderLimit ${"ordersDuringYourSubscriptionPeriod".translate(context: context)}"
                  : "enjoyUnlimitedOrders".translate(context: context),
            ),
            const SizedBox(
              height: 5,
            ),
            setSubscriptionPlanDetailsPoint(
              context: context,
              title: subscriptionDuration != "" &&
                      subscriptionDuration != "unlimited"
                  ? "${"yourSubscriptionWillBeValidFor".translate(context: context)} $subscriptionDuration ${"days".translate(context: context)}"
                  : "enjoySubscriptionForUnlimitedDays"
                      .translate(context: context),
            ),

            const SizedBox(
              height: 5,
            ),
            setSubscriptionPlanDetailsPoint(
              context: context,
              title: isSubscriptionHasCommission
                  ? "$subscriptionCommissionPercentage% ${"commissionWillBeAppliedToYourEarnings".translate(context: context)}"
                  : "noNeedToPayExtraCommission".translate(context: context),
            ),
            const SizedBox(
              height: 5,
            ),
            setSubscriptionPlanDetailsPoint(
              context: context,
              title: isSubscriptionHasCommission
                  ? "${"commissionThreshold".translate(context: context)} ${UiUtils.getPriceFormat(context, double.parse(subscriptionCommissionThreshold))} ${"AmountIsReached".translate(context: context)}"
                  : "noThresholdOnPayOnDeliveryAmount"
                      .translate(context: context),
            ),
            //
            if (isAvailableForPurchase) ...[
              const SizedBox(
                height: 5,
              ),
              buyButton(
                subscriptionId: subscriptionId,
                isLoading: showLoading ?? false,
                context: context,
                onBuyButtonPressed: onBuyButtonPressed.call,
              ),
              const SizedBox(
                height: 5,
              ),
            ],
            if (isActiveSubscription || isPreviousSubscription) ...[
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.greenColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("purchasedOn".translate(context: context)),
                          Text(
                            (subscriptionPurchasedDate ?? "").formatDate(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenColor,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.redColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPreviousSubscription
                                ? "expiredOn".translate(context: context)
                                : "validTill".translate(context: context),
                          ),
                          Text(
                            subscriptionDuration != "" &&
                                    subscriptionDuration != "unlimited"
                                ? (subscriptionExpiryDate ?? "").formatDate()
                                : "-",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.redColor,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (subscriptionDescription != "") ...[
              const SizedBox(
                height: 5,
              ),
              Container(
                constraints: const BoxConstraints(minHeight: 65),
                child: CustomReadMoreTextContainer(
                  text: subscriptionDescription,
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    fontSize: 12,
                  ),
                  readLessColor: Theme.of(context).colorScheme.lightGreyColor,
                  readMoreColor: Theme.of(context).colorScheme.lightGreyColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
