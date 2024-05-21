import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class PromoCode extends StatefulWidget {
  const PromoCode({super.key});

  @override
  PromoCodeState createState() => PromoCodeState();

  static Route<PromoCode> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => DeletePromocodeCubit(),
          ),
        ],
        child: const PromoCode(),
      ),
    );
  }
}

class PromoCodeState extends State<PromoCode> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListener);

  @override
  void initState() {
    context.read<FetchPromocodesCubit>().fetchPromocodeList();
    super.initState();
  }

  void _pageScrollListener() {
    if (_pageScrollController.isEndReached()) {
      context.read<FetchPromocodesCubit>().fetchMorePromocodes();
    }
  }

  void deletePromocode(promocode) {
    final DeletePromocodeCubit deletePromocodeCubit = BlocProvider.of<DeletePromocodeCubit>(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: deletePromocodeCubit,
          child: Builder(
            builder: (BuildContext context) {
              return CustomDialogs.showConfirmDialoge(
                  progressColor: AppColors.whiteColors,
                  context: context,
                  showProgress:
                      context.watch<DeletePromocodeCubit>().state is DeletePromocodeInProgress,
                  confirmButtonColor: AppColors.redColor,
                  confirmButtonName: 'delete'.translate(context: context),
                  cancleButtonName: 'cancle'.translate(context: context),
                  title: 'deletePromocode'.translate(context: context),
                  description: 'deleteServiceDescription'.translate(context: context),
                  onConfirmed: () {
                    if (promocode.id != null) {
                      if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable()) {
                        UiUtils.showDemoModeWarning(context: context);
                        return;
                      }

                      ///delete promocode from here
                      context.read<DeletePromocodeCubit>().deletePromocode(
                        int.parse(promocode.id!),
                        onDelete: () {
                          Navigator.pop(context);
                        },
                      );
                    } else {
                      UiUtils.showMessage(context, 'somethingWentWrong'.translate(context: context),
                          MessageType.error,);
                    }
                  },
                  onCancled: () {},);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        title: CustomText(
          titleText: 'promoCodeLbl'.translate(context: context),
          fontColor: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.bold,
        ),
        leading: UiUtils.setBackArrow(context),
      ),
      floatingActionButton: const AddFloatingButton(
        routeNm: Routes.addPromoCode,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocListener<DeletePromocodeCubit, DeletePromocodeState>(
        listener: (BuildContext context, DeletePromocodeState state) {
          if (state is DeletePromocodeSuccess) {
            context.read<FetchPromocodesCubit>().deletePromocodeFromCubit(state.id);

            UiUtils.showMessage(
                context, 'promocodeDeleteSuccess'.translate(context: context), MessageType.success,);
          }
          if (state is DeletePromocodeFailure) {
            UiUtils.showMessage(context, state.errorMessage.translate(context: context), MessageType.error);
          }
        },
        child: mainWidget(),
      ),
    );
  }

  Widget mainWidget() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FetchPromocodesCubit>().fetchPromocodeList();
      },
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        physics: const AlwaysScrollableScrollPhysics(),
        child: BlocBuilder<FetchPromocodesCubit, FetchPromocodesState>(
          builder: (BuildContext context, FetchPromocodesState state) {
            if (state is FetchPromocodesInProgress) {
              return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemCount: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ShimmerLoadingContainer(
                          child: CustomShimmerContainer(
                        height: 150.rh(context),
                      ),),
                    );
                  },);
            }
            if (state is FetchPromocodesFailure) {
              return Center(
                  child: ErrorContainer(
                      onTapRetry: () {
                        context.read<FetchPromocodesCubit>().fetchPromocodeList();
                      },
                      errorMessage: state.errorMessage.translate(context: context),),);
            }

            if (state is FetchPromocodesSuccess) {
              if (state.promocodes.isEmpty) {
                return NoDataContainer(titleKey: 'noDataFound'.translate(context: context));
              }
              return ListView.separated(
                controller: _pageScrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                itemCount: state.promocodes.length,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                itemBuilder: (BuildContext context, int index) {
                  final PromocodeModel promocode = state.promocodes[index];
                  return CustomContainer(
                      padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
                      bgColor: Theme.of(context).colorScheme.secondaryColor,
                      cornerRadius: 10,
                      child: Column(
                        children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: UiUtils.setNetworkImage(promocode.image!,
                                      ww: 80.rw(context), hh: 85.rh(context), fit: BoxFit.fill,),),
                            ),
                            SizedBox(width: 12.rw(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 2),
                                    child: CustomText(
                                      titleText: promocode.promoCode!,
                                      fontWeight: FontWeight.w700,
                                      fontColor: Theme.of(context).colorScheme.blackColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3, bottom: 2),
                                    child: CustomText(
                                      maxLines: 2,
                                      titleText: promocode.message!,
                                      fontColor: Theme.of(context).colorScheme.blackColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3, bottom: 2),
                                    child: setFromToTime(
                                        startDate: promocode.startDate!.split(' ')[0].formatDate(),
                                        endDate: promocode.endDate!.split(' ')[0].formatDate(),),
                                  ),
                                ],
                              ),
                            )
                          ],),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: setStatusAndButtons(
                              promoCodeStatus: promocode.status!,
                              context,
                              height: 30.rh(context),
                              editAction: () {
                                Navigator.pushNamed(context, Routes.addPromoCode,
                                    arguments: {'promocode': promocode},);
                              },
                              deleteAction: () {
                                deletePromocode(promocode);
                              },
                            ),
                          ),
                        ],
                      ),);
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(
                      height: 20,
                    ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget setStatusAndButtons(BuildContext context,
      {required String promoCodeStatus,
      VoidCallback? editAction,
      VoidCallback? deleteAction,
      double? height,}) {
    //set required later
    return Row(
      children: [
        setStatus(
          status: promoCodeStatus,
        ),
        SizedBox(width: 12.rw(context)),
        SizedBox(
          height: height,
          width: 84,
          child: CustomIconButton(
            imgName: 'edit',
            iconColor: Theme.of(context).colorScheme.accentColor,
            titleText: 'editBtnLbl'.translate(context: context),
            fontSize: 12.0,
            titleColor: Theme.of(context).colorScheme.accentColor,
            borderColor: Theme.of(context).colorScheme.lightGreyColor,
            bgColor: Theme.of(context).colorScheme.secondaryColor,
            onPressed: editAction,
            borderRadius: 5,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: height,
          width: 84,
          child: CustomIconButton(
            imgName: 'delete',
            titleText: 'deleteBtnLbl'.translate(context: context),
            fontSize: 12.0,
            iconColor: Theme.of(context).colorScheme.accentColor,
            borderRadius: 5,
            titleColor: Theme.of(context).colorScheme.accentColor,
            borderColor: Theme.of(context).colorScheme.lightGreyColor,
            bgColor: const Color.fromARGB(0, 255, 255, 255),
            onPressed: deleteAction, //() {},
          ),
        ),
      ],
    );
  }

  Widget setFromToTime({required String startDate, required String endDate}) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 5),
          child: UiUtils.setSVGImage('b_calender',
              imgColor: Theme.of(context).colorScheme.lightGreyColor,),
        ),
        CustomText(
          fontColor: Theme.of(context).colorScheme.lightGreyColor,
          titleText: startDate,
          fontSize: 12,
        ),
        const SizedBox(
          width: 5,
        ),
        CustomText(
          fontColor: Theme.of(context).colorScheme.lightGreyColor,
          titleText: 'toLbl'.translate(context: context),
          fontSize: 12,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: CustomText(
            fontColor: Theme.of(context).colorScheme.lightGreyColor,
            titleText: endDate,
            fontSize: 12,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget setStatus({required String status}) {
    final List<Map> statusFilterMap = [
      {'value': '0', 'title': 'DeActive'.translate(context: context)},
      {'value': '1', 'title': 'Active'.translate(context: context)}
    ];

    final Map currentStatus = statusFilterMap.where((Map element) => element['value'] == status).toList()[0];

    return CustomRoundedButton(
      widthPercentage: 0.22,
      width: 80.rw(context),
      backgroundColor: Theme.of(context).colorScheme.secondaryColor,
      buttonTitle: currentStatus['title'],
      maxLines: 1,

      showBorder: true,
      titleColor: Theme.of(context).colorScheme.accentColor,
      borderColor: Theme.of(context).colorScheme.lightGreyColor,
      textSize: 12,
      height: 30.rh(context),
      radius: 5,
    );

  }
}
