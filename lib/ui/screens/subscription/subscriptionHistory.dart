// import 'package:edemand_partner/app/generalImports.dart';
// import 'package:edemand_partner/cubits/fetchPreviousSubscriptionsCubit.dart';
// import 'package:edemand_partner/ui/screens/subscription/widgets/subscriptionDetailsContainer.dart';
// import 'package:flutter/material.dart';

// class SubscriptionHistoryScreen extends StatefulWidget {
//   const SubscriptionHistoryScreen({super.key});

//   @override
//   SubscriptionHistoryScreenState createState() =>
//       SubscriptionHistoryScreenState();

//   static Route<SubscriptionHistoryScreen> route(RouteSettings routeSettings) {
//     return CupertinoPageRoute(
//       builder: (_) => const SubscriptionHistoryScreen(),
//     );
//   }
// }

// class SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
//   late final ScrollController _pageScrollController = ScrollController()
//     ..addListener(_pageScrollListen);

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void _pageScrollListen() {
//     if (_pageScrollController.isEndReached()) {
//       if (context.read<FetchPreviousSubscriptionsCubit>().hasMoreData()) {
//         context
//             .read<FetchPreviousSubscriptionsCubit>()
//             .fetchMorePreviousSubscriptions();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primaryColor,
//       appBar: AppBar(
//         elevation: 1,
//         centerTitle: true,
//         backgroundColor: Theme.of(context).colorScheme.secondaryColor,
//         title: CustomText(
//           titleText: 'previousSubscriptions'.translate(context: context),
//           fontColor: Theme.of(context).colorScheme.blackColor,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//         leading: UiUtils.setBackArrow(context),
//       ),
//       body: mainWidget(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }

//   Widget getTitleAndDetails(
//       {required String title, required String subDetails}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CustomText(
//           titleText: title.translate(context: context),
//           fontSize: 14,
//           fontColor: Theme.of(context).colorScheme.lightGreyColor,
//         ),
//         const SizedBox(width: 2),
//         CustomText(
//           titleText: subDetails,
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//           fontColor: Theme.of(context).colorScheme.blackColor,
//         ),
//       ],
//     );
//   }

//   Widget showPreviousSubscriptionList({
//     required List<SubscriptionInformation> subscriptionsData,
//     required bool isLoadingMore,
//   }) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(10),
//       controller: _pageScrollController,
//       clipBehavior: Clip.none,
//       child: Column(
//         children: [
//           if (subscriptionsData.isEmpty) ...[
//             Center(
//                 child: NoDataContainer(
//                     titleKey: 'noDataFound'.translate(context: context)))
//           ],
//           if (subscriptionsData.isNotEmpty) ...[
//             Column(
//               children: List.generate(
//                   subscriptionsData.length + (isLoadingMore ? 1 : 0), (index) {
//                 if (index >= subscriptionsData.length) {
//                   return const CircularProgressIndicator();
//                 }
//                 return SubscriptionDetailsContainer(
//                   subscriptionTaxPercentage:
//                       subscriptionsData[index].taxPercenrage ?? "0.00",
//                   subscriptionTitle: subscriptionsData[index].name ?? "",
//                   subscriptionPrice: subscriptionsData[index].price ?? "0",
//                   subscriptionDiscountPrice:
//                       subscriptionsData[index].discountPrice ?? "0",
//                   subscriptionDiscountPriceWithTax:
//                       subscriptionsData[index].discountPriceWithTax ?? "0",
//                   subscriptionPriceWithTax:
//                       subscriptionsData[index].priceWithTax ?? "0",
//                   subscriptionDescription:
//                       subscriptionsData[index].description ?? "",
//                   subscriptionPaymentStatus:
//                       subscriptionsData[index].isPayment ?? "",
//                   isActiveSubscription: false,
//                   needToShowPaymentStatus: true,
//                   isAvailableForPurchase: false,
//                   isPreviousSubscription: true,
//                   subscriptionMaxOrderLimit:
//                       subscriptionsData[index].maxOrderLimit ?? "",
//                   subscriptionDuration:
//                       subscriptionsData[index].duration ?? "0",
//                   isSubscriptionHasCommission:
//                       subscriptionsData[index].isCommision == "yes",
//                   subscriptionCommissionPercentage:
//                       subscriptionsData[index].commissionPercentage ?? "0",
//                   subscriptionCommissionThreshold:
//                       subscriptionsData[index].commissionThreshold ?? "0",
//                   subscriptionId: subscriptionsData[index].id ?? "0",
//                   subscriptionPurchasedDate:
//                       subscriptionsData[index].purchaseDate ?? "",
//                   subscriptionExpiryDate:
//                       subscriptionsData[index].expiryDate ?? "",
//                   showLoading: false,
//                   onBuyButtonPressed: () {},
//                 );
//               }),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget mainWidget() {
//     return RefreshIndicator(
//       onRefresh: () async {
//         context
//             .read<FetchPreviousSubscriptionsCubit>()
//             .fetchPreviousSubscriptions();
//       },
//       child: BlocBuilder<FetchPreviousSubscriptionsCubit,
//           FetchPreviousSubscriptionsState>(
//         builder: (context, state) {
//           if (state is FetchPreviousSubscriptionsFailure) {
//             return Center(
//               child: ErrorContainer(
//                 onTapRetry: () {
//                   context
//                       .read<FetchPreviousSubscriptionsCubit>()
//                       .fetchPreviousSubscriptions();
//                 },
//                 errorMessage: state.errorMessage.translate(context: context),
//               ),
//             );
//           }
//           if (state is FetchPreviousSubscriptionsSuccess) {
//             return state.subscriptionsData.isEmpty
//                 ? Center(
//                     child: NoDataContainer(
//                       titleKey: 'previousSubscriptionsNotFound'
//                           .translate(context: context),
//                     ),
//                   )
//                 : showPreviousSubscriptionList(
//                     subscriptionsData: state.subscriptionsData,
//                     isLoadingMore: state.isLoadingMoreSubscriptions,
//                   );
//           }
//           return ListView.builder(
//             shrinkWrap: true,
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             itemCount: 8,
//             physics: const NeverScrollableScrollPhysics(),
//             clipBehavior: Clip.none,
//             itemBuilder: (BuildContext context, int index) {
//               return const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: ShimmerLoadingContainer(
//                   child: CustomShimmerContainer(
//                     height: 100,
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
