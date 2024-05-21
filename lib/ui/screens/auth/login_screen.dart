import 'package:edemand_partner/cubits/updateFCMCubit.dart';
import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Route route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (BuildContext context) => const LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController =
      TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<FetchSystemSettingsCubit>().getSettings(isAnonymous: true);
  }

  Future<void> _onLoginButtonClick() async {
    FocusScope.of(context).unfocus();
    if (_loginFormKey.currentState!.validate()) {
      final String countryCallingCode =
          context.read<CountryCodeCubit>().getSelectedCountryCode();
      //
      context.read<SignInCubit>().SignIn(
            phoneNumber: _phoneNumberController.text,
            password: _passwordController.text,
            countryCode: countryCallingCode,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        body: BlocConsumer<SignInCubit, SignInState>(
          listener: (BuildContext context, SignInState state) async {
            if (state is SignInSuccess) {
              //
              if (state.error) {
                UiUtils.showMessage(
                    context,
                    state.message.translate(context: context),
                    MessageType.error);
                return;
              }

              context
                  .read<ProviderDetailsCubit>()
                  .setUserInfo(state.providerDetails);
              //
              HiveUtils.setUserIsAuthenticated();
              //
              try {
                final String? fcmToken =
                    await FirebaseMessaging.instance.getToken();
                context.read<UpdateFCMCubit>().updateFCMId(
                    fcmID: fcmToken ?? "",
                    platform: Platform.isAndroid ? "android" : "ios");
              } catch (_) {}

              if (state.providerDetails.providerInformation?.isApproved ==
                  '1') {
                if (state.providerDetails.subscriptionInformation
                        ?.isSubscriptionActive ==
                    "active") {
                  Future.delayed(
                    Duration.zero,
                    () {
                      Navigator.pushReplacementNamed(context, Routes.main);
                    },
                  );
                } else {
                  Future.delayed(
                    Duration.zero,
                    () {
                      Navigator.of(context).pushReplacementNamed(
                        Routes.main,
                        // arguments: {"from": "login"},
                      );
                    },
                  );
                }
              } else {
                Future.delayed(
                  Duration.zero,
                  () {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.registration,
                      arguments: {'isEditing': false},
                    );
                  },
                );
              }
            }
            if (state is SignInFailure) {
              Future.delayed(
                Duration.zero,
                () {
                  UiUtils.showMessage(
                      context,
                      state.errorMessage.translate(context: context),
                      MessageType.error);
                },
              );
            }
          },
          builder: (BuildContext context, SignInState state) {
            return Form(
              key: _loginFormKey,
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: Container(
                  height: MediaQuery.sizeOf(context).height,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      UiUtils.setSVGImage(
                        'logo_partner_casdd-01',
                        width: 100.rw(context),
                        height: 108.rh(context),
                        boxFit: BoxFit.cover,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        'welcome-provider'.translate(context: context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 28.rf(context),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      CustomTextFormField(
                        controller: _phoneNumberController,
                        textInputType: TextInputType.phone,
                        inputFormatters: UiUtils.allowOnlyDigits(),
                        isDense: false,
                        validator: (String? value) {
                          return Validator.validateNumber(value!);
                        },
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        // borderColor: Theme.of(context).colorScheme.accentColor,
                        isRoundedBorder: true,
                        backgroundColor: Colors.transparent,
                        hintText:
                            'enterMobileNumber'.translate(context: context),
                        hintTextColor:
                            Theme.of(context).colorScheme.lightGreyColor,
                        prefix: Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 12.0, bottom: 2),
                          child:
                              BlocBuilder<CountryCodeCubit, CountryCodeState>(
                            builder:
                                (BuildContext context, CountryCodeState state) {
                              String code = '--';

                              if (state is CountryCodeFetchSuccess) {
                                code = state.selectedCountry!.callingCode;
                              }

                              return SizedBox(
                                height: 27.rh(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (Constant.allowOnlySingleCountry) {
                                          return;
                                        }
                                        Navigator.pushNamed(context,
                                                Routes.countryCodePickerRoute)
                                            .then((Object? value) {
                                          Future.delayed(const Duration(
                                                  milliseconds: 250))
                                              .then((value) {
                                            context
                                                .read<CountryCodeCubit>()
                                                .fillTemporaryList();
                                          });
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Builder(
                                            builder: (BuildContext context) {
                                              if (state
                                                  is CountryCodeFetchSuccess) {
                                                return SizedBox(
                                                  width: 35.rw(context),
                                                  height: 27.rh(context),
                                                  child: Image.asset(
                                                    state.selectedCountry!.flag,
                                                    package:
                                                        countryCodePackageName,
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              }
                                              if (state
                                                  is CountryCodeFetchFail) {
                                                return ErrorContainer(
                                                    errorMessage: state.error
                                                        .toString()
                                                        .translate(
                                                            context: context));
                                              }
                                              return const CircularProgressIndicator();
                                            },
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          if (!Constant.allowOnlySingleCountry)
                                            UiUtils.setSVGImage(
                                              'sp_down',
                                              height: 5,
                                              width: 5,
                                              imgColor: Theme.of(context)
                                                  .colorScheme
                                                  .accentColor,
                                            ),
                                        ],
                                      ),
                                    ),
                                    VerticalDivider(
                                      thickness: 1,
                                      indent: 6,
                                      endIndent: 6,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightGreyColor,
                                    ),
                                    Text(
                                      code,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomTextFormField(
                        controller: _passwordController,
                        isDense: false,
                        isRoundedBorder: true,
                        isPswd: true,
                        backgroundColor: Colors.transparent,
                        hintText:
                            'enterYourPasswrd'.translate(context: context),
                        hintTextColor:
                            Theme.of(context).colorScheme.lightGreyColor,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      buildForgotPasswordLabel(),
                      const SizedBox(
                        height: 20,
                      ),
                      buildLoginButton(context,
                          showProgress: state is SignInInProgress),
                      const SizedBox(
                        height: 25,
                      ),
                      buildNewRegistrationContainer(),
                      const SizedBox(
                        height: 40,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'byContinueYouAccept'
                                    .translate(context: context),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .blackColor
                                      .withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.appSettings,
                                          arguments: {
                                            'title': 'termsCondition'
                                          },
                                        );
                                      },
                                      child: Text(
                                        'termsConditionLbl'
                                            .translate(context: context),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .blackColor,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' & ',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.appSettings,
                                          arguments: {'title': 'privacyPolicy'},
                                        );
                                      },
                                      child: Text(
                                        'privacyPolicyLbl'
                                            .translate(context: context),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .blackColor,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      // buildRegisterButton()
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildForgotPasswordLabel() {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      child: InkWell(
        child: Text(
          'forgotPassword'.translate(context: context),
          style: TextStyle(
            color: Theme.of(context).colorScheme.accentColor,
            fontSize: 14,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.sendOTPScreen,
            arguments: {
              'screenTitle': 'forgotPassword',
              'screenSubTitle':
                  'weWillTextYouVerificationCodeToResetYourPassword'
            },
          );
        },
      ),
    );
  }

  Widget buildLoginButton(BuildContext context, {bool? showProgress}) {
    return CustomRoundedButton(
      onTap: _onLoginButtonClick,
      buttonTitle: 'login'.translate(context: context),
      widthPercentage: 1,
      backgroundColor: Theme.of(context).colorScheme.accentColor,
      showBorder: false,
      child: (showProgress ?? false)
          ? CircularProgressIndicator(
              color: AppColors.whiteColors,
            )
          : null,
    );
  }

  Row buildNewRegistrationContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${"notMember".translate(context: context)} ",
          style: TextStyle(
            color: Theme.of(context).colorScheme.accentColor,
            fontWeight: FontWeight.w400,
            fontFamily: 'PlusJakartaSans',
            fontStyle: FontStyle.normal,
            fontSize: 16.0,
          ),
        ),
        InkWell(
          child: Text(
            'registerNow'.translate(context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.accentColor,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
              fontStyle: FontStyle.normal,
              fontSize: 16.0,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.sendOTPScreen,
              arguments: {
                'screenTitle': 'enterYouMobile',
                'screenSubTitle': 'weWillSendYouCode'
              },
            );
          },
        ),
      ],
    );
  }
}
