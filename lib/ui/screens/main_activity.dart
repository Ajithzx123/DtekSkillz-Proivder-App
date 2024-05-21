import 'package:edemand_partner/cubits/updateFCMCubit.dart';
import 'package:flutter/material.dart';

import '../../app/generalImports.dart';
import '../../utils/appQuickActions.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route<MainActivity> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MainActivity(key: Constant.bottomNavigationBarGlobalKey),
    );
  }
}

class MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  final TextEditingController _passwordControllerDeleteAccount =
      TextEditingController();
  GlobalKey<FormState> deleteAccountFormKey = GlobalKey();

  ValueNotifier<int> selectedIndexOfBottomNavigationBar = ValueNotifier(0);
  ValueNotifier<String> nameOfSelectedIndexOfBottomNavigationBar =
      ValueNotifier('');

  late PageController pageController;

  bool darkTheme = false;
  List<ScrollController> scrollControllerList = [];

  @override
  void initState() {
    super.initState();
    //
    for (int i = 0; i < 4; i++) {
      scrollControllerList.add(ScrollController());
    }
    //
    AppQuickActions.initAppQuickActions();
    AppQuickActions.createAppQuickActions();
    //

    Future.delayed(
      Duration.zero,
      () {
        //Initialize notifications
        LocalAwesomeNotification().init(context);
        NotificationService.init(context);
        //
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'homeTabTitleLbl'.translate(context: context);
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'homeTabTitleLbl'.translate(context: context);
        try {
          context
              .read<ProviderDetailsCubit>()
              .setUserInfo(HiveUtils.getProviderDetails());
        } catch (_) {}
      },
    );

    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    for (int i = 0; i < 4; i++) {
      scrollControllerList[i].dispose();
    }
    super.dispose();
  }

  String _getUserName() {
    return context
            .watch<ProviderDetailsCubit>()
            .providerDetails
            .user
            ?.username ??
        '';
  }

  String _getEmail() {
    return context.watch<ProviderDetailsCubit>().providerDetails.user?.email ??
        '';
  }

  dynamic getProfileImage() {
    return context.watch<ProviderDetailsCubit>().providerDetails.user?.image ??
        '';
  }

  bool doUserHasProfileImage() {
    return context.watch<ProviderDetailsCubit>().providerDetails.user?.image !=
            '' ||
        context.watch<ProviderDetailsCubit>().providerDetails.user?.image !=
            null;
  }

  Future<void> _deleteProviderAccount() async {
    final BlocProvider<SignInCubit> passwordPromptDialoge = BlocProvider(
      create: (BuildContext context) => SignInCubit(),
      child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
        listener: (BuildContext context, DeleteAccountState state) {
          if (state is DeleteAccountSuccess) {
            //
            AppQuickActions.clearShortcutItems();
            //
            Navigator.of(context).popUntil((Route route) => route.isFirst);
            Navigator.pushReplacementNamed(context, Routes.loginScreenRoute);
          }
        },
        child: BlocConsumer<SignInCubit, SignInState>(
          listener: (BuildContext c, SignInState state) {
            if (state is SignInSuccess) {
              context.read<DeleteAccountCubit>().deleteAccount();
            }
          },
          builder: (BuildContext context, SignInState state) {
            return CustomDialogs.showTextFieldDialoge(
              context,
              controller: _passwordControllerDeleteAccount,
              formKey: deleteAccountFormKey,
              validator: (String p0) {},
              title: 'deleteAccount'.translate(context: context),
              hintText: 'enterYourPasswrd',
              isPasswordField: true,
              message: (state is SignInFailure)
                  ? state.errorMessage.translate(context: context)
                  : '',
              confirmButtonName: 'deleteBtnLbl'.translate(context: context),
              showProgress: state is SignInInProgress,
              progressColor: AppColors.whiteColors,
              confirmButtonColor: AppColors.redColor,
              onConfirmed: () async {
                //
                final String countryCode = context
                        .read<ProviderDetailsCubit>()
                        .providerDetails
                        .user
                        ?.countryCode ??
                    '';
                final String mobileNumber = context
                        .read<ProviderDetailsCubit>()
                        .providerDetails
                        .user
                        ?.phone ??
                    '';

                if (_passwordControllerDeleteAccount.text.trim().isEmpty) {
                  UiUtils.showMessage(
                    context,
                    'enterYourPasswrd'.translate(context: context),
                    MessageType.error,
                  );
                  return;
                }
                //
                if (context
                    .read<FetchSystemSettingsCubit>()
                    .isDemoModeEnable()) {
                  UiUtils.showMessage(
                    context,
                    'demoModeWarning'.translate(context: context),
                    MessageType.warning,
                  );
                  Navigator.pop(context);
                  return;
                }
                //
                context.read<SignInCubit>().SignIn(
                      phoneNumber: mobileNumber,
                      password: _passwordControllerDeleteAccount.text.trim(),
                      countryCode: countryCode,
                    );
              },
              onCancled: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );

    final AlertDialog confirmDialoge = CustomDialogs.showConfirmDialoge(
      context: context,
      title: 'deleteAccount'.translate(context: context),
      description: 'deleteAcountDescription'.translate(context: context),
      confirmButtonName: 'Delete',
      confirmTextColor: AppColors.whiteColors,
      confirmButtonColor: AppColors.redColor,
      onConfirmed: () async {
        Navigator.pop(context);
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return passwordPromptDialoge;
          },
        );
        _passwordControllerDeleteAccount.text = '';
      },
      onCancled: () {},
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return confirmDialoge;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    darkTheme = context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (selectedIndexOfBottomNavigationBar.value != 0) {
              selectedIndexOfBottomNavigationBar.value = 0;
              /* setState(() {
                selectedIndexOfBottomNavigationBar.value = 0;
              });*/
              pageController
                  .jumpToPage(selectedIndexOfBottomNavigationBar.value);
              return false;
            }

            return true;
          },
          child: Scaffold(
            bottomNavigationBar: bottomBar(),
            appBar: AppBar(
              iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.accentColor),
              title: ValueListenableBuilder(
                valueListenable: nameOfSelectedIndexOfBottomNavigationBar,
                builder: (BuildContext context, Object? value, Widget? child) {
                  return Text(
                    nameOfSelectedIndexOfBottomNavigationBar.value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              backgroundColor: Theme.of(context).colorScheme.secondaryColor,
              elevation: 1,
              centerTitle: true,
            ),
            onDrawerChanged: (bool a) {
              FocusManager.instance.primaryFocus?.unfocus();
              FocusScope.of(context).unfocus();
            },
            drawer: drawer(),
            body: ValueListenableBuilder(
              valueListenable: selectedIndexOfBottomNavigationBar,
              builder: (BuildContext context, Object? value, Widget? child) {
                return PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: onItemTapped,
                  children: [
                    HomeScreen(scrollController: scrollControllerList[0]),
                    BookingScreen(scrollController: scrollControllerList[1]),
                    ServicesScreen(scrollController: scrollControllerList[2]),
                    ReviewsScreen(scrollController: scrollControllerList[3]),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    final int previousSelectedIndex = selectedIndexOfBottomNavigationBar.value;

    switch (index) {
      case 1:
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'bookingsTitleLbl'.translate(context: context);
        break;
      case 2:
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'servicesTitleLbl'.translate(context: context);
        break;
      case 3:
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'reviewsTitleLbl'.translate(context: context);
        break;
      default: //index = 0
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'homeTabTitleLbl'.translate(context: context);
        break;
    }
    setState(() {
      selectedIndexOfBottomNavigationBar.value = index;
    });

    pageController.jumpToPage(selectedIndexOfBottomNavigationBar.value);
    try {
      if (previousSelectedIndex == index &&
          scrollControllerList[index].positions.isNotEmpty) {
        scrollControllerList[index].animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
      }
    } catch (_) {}
  }

  Widget drawer() {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryColor,
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.registration,
                    arguments: {'isEditing': true});
              },
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsetsDirectional.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.blackColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: doUserHasProfileImage()
                          ? CustomCachedNetworkImage(
                              imageUrl: getProfileImage(),
                            )
                          : UiUtils.setSVGImage("dr_profile"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          titleText: _getUserName(),
                          fontColor: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w700,
                        ),
                        CustomText(
                          titleText: _getEmail(),
                          fontColor: Theme.of(context).colorScheme.blackColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          maxLines: 2,
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .blackColor
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.edit,
                        color: Theme.of(context).colorScheme.blackColor,
                        size: 16),
                  ),
                ],
              ),
            ),
          ),
          buildDrawerItem(
            icon: 'categories',
            title: 'categoriesLbl'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.categories);
            },
          ),
          buildDrawerItem(
            icon: 'promoCode',
            title: 'promoCodeLbl'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.promoCode);
            },
          ),
          buildDrawerItem(
            icon: 'cash_collection',
            title: 'cashCollection'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.cashCollection);
            },
          ),
          buildDrawerItem(
            icon: 'settlement_history',
            title: 'settlementHistory'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                Routes.settlementHistoryScreen,
              );
            },
          ),
          buildDrawerItem(
            icon: 'withdrawal_history',
            title: 'withdrawalRequest'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.withdrawalRequests);
            },
          ),
          // buildDrawerItem(
          //   icon: 'subscription',
          //   title: 'subscriptions'.translate(context: context),
          //   onItemTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.of(context).pushNamed(Routes.subscriptionScreen,
          //         arguments: {"from": "drawer"});
          //   },
          // ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          buildGroupTitle('appPrefsTitleLbl'.translate(context: context)),
          buildDrawerItem(
            icon: 'language',
            title: 'languageLbl'.translate(context: context),
            onItemTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                builder: (BuildContext context) {
                  return const ChooseLanguageBottomSheet();
                },
              );
            },
          ),
          buildDrawerItem(
            icon: 'darkMode',
            title: 'darkThemeLbl'.translate(context: context),
            isSwitch: true,
            onItemTap: () {
              context.read<AppThemeCubit>().toggleTheme();
              darkTheme = context.read<AppThemeCubit>().isDarkMode();
              setState(() {});
            },
          ),
          buildDrawerItem(
            icon: 'change_password',
            title: 'changePassword'.translate(context: context),
            onItemTap: () async {
              await showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
                    topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
                  ),
                ),
                enableDrag: true,
                isScrollControlled: true,
                builder: (BuildContext context) => Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: const ChangePasswordBottomSheet(),
                ),
              );
            },
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          buildGroupTitle('helpPrivacyTitleLbl'.translate(context: context)),
          buildDrawerItem(
            icon: 'contact',
            title: 'contactUs'.translate(context: context),
            onItemTap: () {
              Navigator.pushNamed(context, Routes.appSettings,
                  arguments: {'title': 'contactUs'});
            },
          ),
          buildDrawerItem(
            icon: 'help',
            title: 'aboutUs'.translate(context: context),
            onItemTap: () {
              Navigator.pushNamed(context, Routes.appSettings,
                  arguments: {'title': 'aboutUs'});
            },
          ),
          buildDrawerItem(
            icon: 'privacy_policy',
            title: 'privacyPolicyLbl'.translate(context: context),
            onItemTap: () {
              Navigator.pushNamed(
                context,
                Routes.appSettings,
                arguments: {'title': 'privacyPolicy'},
              );
            },
          ),
          buildDrawerItem(
            icon: 'terms',
            title: 'termsConditionLbl'.translate(context: context),
            onItemTap: () {
              Navigator.pushNamed(
                context,
                Routes.appSettings,
                arguments: {'title': 'termsCondition'},
              );
            },
          ),
          buildDrawerItem(
            icon: 'logout',
            title: 'logoutLbl'.translate(context: context),
            onItemTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialogs.showConfirmDialoge(
                    context: context,
                    title: 'logoutLbl'.translate(context: context),
                    cancleButtonName: 'cancel'.translate(context: context),
                    confirmButtonName: 'logoutLbl'.translate(context: context),
                    confirmButtonColor: AppColors.redColor,
                    description: 'areYouSureLogout'.translate(context: context),
                    onConfirmed: () async {
                      print("here");
                      try {
                        await context.read<UpdateFCMCubit>().updateFCMId(
                            fcmID: "",
                            platform: Platform.isAndroid ? "android" : "ios");
                      } catch (e) {
                        print("erorr ${e.toString()}");
                      }

                      await AuthRepository().logout(context);

                      // await HiveUtils.logoutUser();
                    },
                    onCancled: () {},
                  );
                },
              );
            },
          ),
          ListTile(
            tileColor: Colors.redAccent.withOpacity(0.05),

            visualDensity: const VisualDensity(vertical: -4),
            //change -4 to required one TO INCREASE SPACE BTWN ListTiles
            leading: const Icon(Icons.delete, color: AppColors.redColor),
            title: CustomText(
              titleText: 'deleteAccount'.translate(context: context),
              fontSize: 15.0,
              fontColor: AppColors.redColor,
            ),
            selectedTileColor: Theme.of(context).colorScheme.lightGreyColor,
            onTap: () async {
              await _deleteProviderAccount();
            },
            hoverColor: Theme.of(context).colorScheme.lightGreyColor,
            horizontalTitleGap: 0,
          )
        ],
      ),
    );
  }

  Widget buildGroupTitle(String titleTxt) {
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 10, top: 10, bottom: 10),
      child: CustomText(
        titleText: titleTxt,
        fontSize: 14,
        fontColor: Theme.of(context).colorScheme.blackColor,
      ),
    );
  }

  Widget buildDrawerItem({
    required String? icon,
    required String title,
    required VoidCallback onItemTap,
    bool? isSwitch,
  }) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -4),
      //change -4 to required one TO INCREASE SPACE BTWN ListTiles
      leading: UiUtils.setSVGImage(
        icon!,
        imgColor: (title == 'logoutLbl'.translate(context: context))
            ? AppColors.redColor
            : Theme.of(context).colorScheme.accentColor,
        height: 20,
        width: 20,
      ),
      trailing: isSwitch ?? false
          ? CupertinoSwitch(
              activeColor: Theme.of(context).colorScheme.secondaryColor,
              thumbColor: Theme.of(context).colorScheme.blackColor,
              trackColor: Theme.of(context).colorScheme.secondaryColor,
              value: darkTheme,
              onChanged: (bool val) {
                setState(() {
                  darkTheme = !darkTheme;
                });
                onItemTap.call();
              },
            )
          : const SizedBox.shrink(),
      title: CustomText(
        titleText: title,
        fontWeight: (icon != '') ? FontWeight.w500 : FontWeight.normal,
        fontSize: 15.0,
        fontColor: (title == 'logoutLbl'.translate(context: context))
            ? AppColors.redColor
            : Theme.of(context).colorScheme.blackColor,
      ),
      selectedTileColor: Theme.of(context).colorScheme.lightGreyColor,
      onTap: onItemTap,
      hoverColor: Theme.of(context).colorScheme.lightGreyColor,
      horizontalTitleGap: 0,
    );
  }

  BottomAppBar bottomBar() {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.secondaryColor,
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            setBottomNavigationbarItem(
                0, 'home', 'homeTab'.translate(context: context)),
            setBottomNavigationbarItem(
                1, 'booking', 'bookingTab'.translate(context: context)),
            setBottomNavigationbarItem(
                2, 'services', 'serviceTab'.translate(context: context)),
            setBottomNavigationbarItem(
                3, 'reviews', 'reviewsTab'.translate(context: context))
          ],
        ),
      ),
    );
  }

  Widget setBottomNavigationbarItem(int index, String imgName, String nameTxt) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => onItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsetsDirectional.only(top: 8),
                child: UiUtils.setSVGImage(
                  imgName,
                  imgColor: selectedIndexOfBottomNavigationBar.value != index
                      ? Theme.of(context).colorScheme.lightGreyColor
                      : Theme.of(context).colorScheme.accentColor,
                ),
              ),
              CustomText(
                titleText: nameTxt,
                fontSize: 12,
                fontColor: (selectedIndexOfBottomNavigationBar.value == index)
                    ? Theme.of(context).colorScheme.accentColor
                    : Theme.of(context).colorScheme.lightGreyColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
