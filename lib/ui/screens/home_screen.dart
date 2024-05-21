import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  int gridItems = 4;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    //
    context.read<FetchStatisticsCubit>().getStatistics();
    context.read<FetchSystemSettingsCubit>().getSettings(isAnonymous: false);

    super.initState();
  }

  String? _getStatesValue(StatisticsModel states, int index) {
    switch (index) {
      case 0:
        return states.totalOrders;
      case 1:
        return states.totalCancles;
      case 2:
        return states.totalServices;
      case 3:
        return states.totalBalance;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    FirebaseMessaging.instance.getToken().then((String? value) {});
    FirebaseMessaging.instance.getToken();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        body: dashboard(),
      ),
    );
  }

  Widget dashboard() {
    final List<Map> cardDetails = [
      {
        'id': '0',
        'imgName':
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? 'ttl_booking'
                : 'ttl_booking_white',
        'title': 'totalBookingLbl'.translate(context: context),
        'showCurrencyIcon': false,
      },
      {
        'id': '1',
        'imgName':
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? 'ttl_cancel'
                : 'ttl_cancel_white',
        'title': 'totalCancelLbl'.translate(context: context),
        'showCurrencyIcon': false,
      },
      {
        'id': '2',
        'imgName': 'ttl_services',
        'title': 'totalServicesLbl'.translate(context: context),
        'imgColor': Theme.of(context).colorScheme.accentColor,
        'showCurrencyIcon': false,
      },
      {
        'id': '3',
        'imgName':
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? 'ttl_earning'
                : 'ttl_earning_white',
        'title': 'totalEarningLbl'.translate(context: context),
        'showCurrencyIcon': true,
      }
    ];
    return RefreshIndicator(
      onRefresh: () async {
        //
        context.read<FetchStatisticsCubit>().getStatistics();
        context
            .read<FetchSystemSettingsCubit>()
            .getSettings(isAnonymous: false);
      },
      child: BlocBuilder<FetchStatisticsCubit, FetchStatisticsState>(
        builder: (BuildContext context, FetchStatisticsState state) {
          if (state is FetchStatisticsInProgress) {
            return SingleChildScrollView(
              controller: widget.scrollController,
              clipBehavior: Clip.none,
              child: Column(
                children: [
                  ScrollConfiguration(
                    behavior: CustomScrollBehaviour(),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      itemCount: gridItems,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing:
                            10, //horizontal spacing between 2 cards
                        childAspectRatio: MediaQuery.sizeOf(context).width /
                            (MediaQuery.sizeOf(context).height / 2.2),
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return const ShimmerLoadingContainer(
                            child: CustomShimmerContainer());
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        height: 250.rh(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is FetchStatisticsFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<FetchStatisticsCubit>().getStatistics();
                  context
                      .read<FetchSystemSettingsCubit>()
                      .getSettings(isAnonymous: false);
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }

          if (state is FetchStatisticsSuccess) {
            return SingleChildScrollView(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  ScrollConfiguration(
                    behavior: CustomScrollBehaviour(),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: gridItems,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        crossAxisSpacing:
                            5, //horizontal spacing between 2 cards
                        childAspectRatio: 1.1,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          color: Theme.of(context).colorScheme.secondaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 38,
                                  child: UiUtils.setSVGImage(
                                    cardDetails[index]['imgName'],
                                    imgColor: cardDetails[index]['imgColor'],
                                  ),
                                ),
                                CustomText(
                                  titleText: cardDetails[index]['title'],
                                  fontSize: 14,
                                  fontColor:
                                      Theme.of(context).colorScheme.blackColor,
                                ),
                                CustomTweenAnimation(
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  beginValue: 0,
                                  endValue: double.parse(_getStatesValue(
                                          state.statistics, index) ??
                                      ""),
                                  durationInSeconds: 1,
                                  builder: (BuildContext context, double value,
                                          Widget? child) =>
                                      CustomText(
                                    titleText:
                                        "${cardDetails[index]['showCurrencyIcon'] ? Constant.systemCurrency : ""}${value.toStringAsFixed(0)}",
                                    fontWeight: FontWeight.w700,
                                    fontColor: Theme.of(context)
                                        .colorScheme
                                        .blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.statistics.monthlyEarnings?.monthlySales
                          ?.isNotEmpty ??
                      false) ...[
                    SizedBox(
                      height: 350,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 15, right: 15, left: 15),
                        child: MonthlyEarningBarChart(
                          monthlySales:
                              state.statistics.monthlyEarnings!.monthlySales!,
                        ),
                      ),
                    ),
                  ],
                  if (state.statistics.caregories?.isNotEmpty ?? false) ...[
                    SizedBox(
                      height: 260,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CategoryPieChart(
                            categoryProductCounts:
                                state.statistics.caregories!),
                      ),
                    )
                  ]
                ],
              ),
            );
          }

          return Container();
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
