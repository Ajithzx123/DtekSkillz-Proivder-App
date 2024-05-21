import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  CategoriesState createState() => CategoriesState();

  static Route<Categories> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => FetchCategoriesCubit(),
        child: const Categories(),
      ),
    );
  }
}

class CategoriesState extends State<Categories> {
  DateTime currDate = DateTime.now();
  TimeOfDay currTime = TimeOfDay.now();
  late final ScrollController _pageScrollcontroller = ScrollController()
    ..addListener(_pageScrollListen);
  late Map categoryStatus = {
    '0': 'deActive'.translate(context: context),
    '1': 'active'.translate(context: context),
  };

  void _pageScrollListen() {
    if (_pageScrollcontroller.isEndReached()) {
      if (context.read<FetchCategoriesCubit>().hasMoreCategories()) {
        context.read<FetchCategoriesCubit>().fetchMoreCategories();
      }
    }
  }

  @override
  void initState() {
    context.read<FetchCategoriesCubit>().fetchCategories();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    categoryStatus = {
      '0': 'deActive'.translate(context: context),
      '1': 'active'.translate(context: context),
    };
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        centerTitle: true,
        title: CustomText(
          titleText: 'categoriesLbl'.translate(context: context),
          fontColor: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        leading: UiUtils.setBackArrow(context),
      ),
      body: mainWidget(),
    );
  }

  Widget mainWidget() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FetchCategoriesCubit>().fetchCategories();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15),
        clipBehavior: Clip.none,
        physics: const AlwaysScrollableScrollPhysics(),
        child: BlocBuilder<FetchCategoriesCubit, FetchCategoriesState>(
          builder: (BuildContext context, FetchCategoriesState state) {
            if (state is FetchCategoriesInProgress) {
              return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemCount: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ShimmerLoadingContainer(
                          child: CustomShimmerContainer(
                        height: MediaQuery.sizeOf(context).height * 0.19,
                      ),),
                    );
                  },);
            }
            if (state is FetchCategoriesFailure) {
              return Center(
                  child: ErrorContainer(
                      onTapRetry: () {
                        context.read<FetchCategoriesCubit>().fetchCategories();
                      },
                      errorMessage: state.errorMessage.translate(context: context),),);
            }

            if (state is FetchCategoriesSuccess) {
              if (state.categories.isEmpty) {
                return NoDataContainer(titleKey: 'noDataFound'.translate(context: context));
              }
              return Column(
                children: [
                  ListView.separated(
                    controller: _pageScrollcontroller,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    itemCount: state.categories.length,
                    physics: const NeverScrollableScrollPhysics(),
                    clipBehavior: Clip.none,
                    itemBuilder: (BuildContext context, int index) {
                      final CategoryModel categorie = state.categories[index];
                      return GestureDetector(
                        onTap: () {},
                        child: CustomContainer(
                            height: 115.rh(context),
                            padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
                            bgColor: Theme.of(context).colorScheme.secondaryColor,
                            cornerRadius: 10,
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              SizedBox(
                                  width: 83.rw(context),
                                  child: setImage(image: categorie.categoryImage!),),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    //.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        titleText: categorie.name!,
                                        fontWeight: FontWeight.w700,
                                        fontColor: Theme.of(context).colorScheme.blackColor,
                                      ),
                                      /*setCommissionAndStatus(
                                        lhs: "adminCommLbl".translate(context: context),
                                        rhs: categorie.adminCommission!,
                                      ),*/
                                      setCommissionAndStatus(
                                        lhs: 'statusLbl'.translate(context: context),
                                        rhs: categoryStatus[categorie.status],
                                      ),
                                      Container()
                                    ],
                                  ),
                                ),
                              )
                            ],),),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(
                          height: 20,
                        ),
                  ),
                  if (state.isLoadingMoreCategories)
                    CircularProgressIndicator(
                      color: AppColors.whiteColors,
                    )
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget setImage({required String image}) {
    return Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: UiUtils.setNetworkImage(image, ww: 90, hh: 110),),);
  }

  Widget setCommissionAndStatus({required String lhs, required String rhs}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
          child: Center(
            child: CustomText(
              titleText: lhs,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontColor: Theme.of(context).colorScheme.blackColor,
            ),
          ),
        ),
        Container(
          height: 30,
          width: MediaQuery.sizeOf(context).width * 0.2,
          decoration: BoxDecoration(
            color: rhs == 'Active' ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: CustomText(
              titleText: (lhs == 'adminCommLbl'.translate(context: context))
                  ? rhs.formatPercentage()
                  : rhs,
              fontWeight: (lhs == 'adminCommLbl'.translate(context: context))
                  ? FontWeight.w700
                  : FontWeight.w400,
              fontSize: 13,
              fontColor: rhs == 'Active' ? Colors.green : Colors.red,
            ),
          ),
        )
      ],
    );
  }

  Widget setDateTime({required String date, required String time}) {
    return Row(
      children: [
        setIconAndText(
          iconName: 'b_clock', //'b_calendar',
          txtVal: date,
        ), // use categoryList[index]['date']
        const SizedBox(width: 10),
        setIconAndText(iconName: 'b_clock', txtVal: time), //use categoryList[index]['time']
      ],
    );
  }

  Widget setIconAndText({required String iconName, required String txtVal}) {
    return Row(
      children: [
        UiUtils.setSVGImage(iconName),
        const SizedBox(width: 2),
        CustomText(
          titleText: txtVal,
          //'formatted date',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontColor: Theme.of(context).colorScheme.blackColor,
        )
      ],
    );
  }
}
