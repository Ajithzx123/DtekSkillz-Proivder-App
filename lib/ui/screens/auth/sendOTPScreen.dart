// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class SendOTPScreen extends StatefulWidget {
  const SendOTPScreen({
    super.key,
    required this.screenTitle,
    required this.screenSubTitle,
  });
  final String screenTitle;
  final String screenSubTitle;

  @override
  State<SendOTPScreen> createState() => _SendOTPScreenState();

  static Route route(RouteSettings routeSettings) {
    final Map<String, dynamic> arguments =
        routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) {
        return SendOTPScreen(
          screenTitle: arguments['screenTitle'],
          screenSubTitle: arguments['screenSubTitle'],
        );
      },
    );
  }
}

class _SendOTPScreenState extends State<SendOTPScreen> {
  String phoneNumberWithCountryCode = '';
  String onlyPhoneNumber = '';
  String countryCode = '';

  final GlobalKey<FormState> verifyPhoneNumberFormKey = GlobalKey<FormState>();
  final TextEditingController _numberFieldController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _numberFieldController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onContinueButtonClicked() {
    UiUtils.removeFocus();

    final bool isvalidNumber =
        verifyPhoneNumberFormKey.currentState!.validate();

    if (isvalidNumber) {
      //
      final String countryCallingCode =
          context.read<CountryCodeCubit>().getSelectedCountryCode();
      //
      phoneNumberWithCountryCode =
          countryCallingCode + _numberFieldController.text;
      onlyPhoneNumber = _numberFieldController.text;
      countryCode = countryCallingCode;
      //
      context.read<VerifyPhoneNumberFromAPICubit>().verifyPhoneNumberFromAPI(
            mobileNumber: onlyPhoneNumber,
            countryCode: countryCode,
          );
    }
  }

  Padding _buildPhoneNumberFiled() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 25),
      child: CustomTextFormField(
        controller: _numberFieldController,
        isDense: false,
        isRoundedBorder: true,
        backgroundColor: Colors.transparent,
        textInputType: TextInputType.phone,
        hintText: 'hintMobileNumber'.translate(context: context),
        hintTextColor: Theme.of(context).colorScheme.lightGreyColor,
        textInputAction: TextInputAction.done,
        prefix: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12.0, bottom: 2),
          child: BlocBuilder<CountryCodeCubit, CountryCodeState>(
            builder: (BuildContext context, CountryCodeState state) {
              String code = '--';

              if (state is CountryCodeFetchSuccess) {
                code = state.selectedCountry!.callingCode;
              }

              return IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        if (Constant.allowOnlySingleCountry) {
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          Routes.countryCodePickerRoute,
                        ).then((Object? value) {
                          Future.delayed(const Duration(milliseconds: 250))
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
                              if (state is CountryCodeFetchSuccess) {
                                return SizedBox(
                                  width: 35,
                                  height: 25,
                                  child: Image.asset(
                                    state.selectedCountry!.flag,
                                    package: countryCodePackageName,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              if (state is CountryCodeFetchFail) {
                                return ErrorContainer(
                                  errorMessage: state.error
                                      .toString()
                                      .translate(context: context),
                                );
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
                              imgColor:
                                  Theme.of(context).colorScheme.accentColor,
                            ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      thickness: 1,
                      indent: 6,
                      endIndent: 6,
                      color: Theme.of(context).colorScheme.lightGreyColor,
                    ),
                    Text(
                      code,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
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
        validator: (String? value) {
          return Validator.validateNumber(value!);
        },
      ),
    );
  }

  Widget _buildHeading() {
    return Text(
      widget.screenTitle.translate(context: context),
      style: TextStyle(
        color: Theme.of(context).colorScheme.blackColor,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        fontSize: 28.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubHeading() {
    return Text(
      widget.screenSubTitle.translate(context: context),
      style: TextStyle(
        color: Theme.of(context).colorScheme.blackColor.withOpacity(0.5),
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        fontSize: 16.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          elevation: 1,
          centerTitle: true,
          leading: UiUtils.setBackArrow(context),
        ),
        body: Form(
          key: verifyPhoneNumberFormKey,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(28.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    UiUtils.setSVGImage(
                      'logo_partner_casdd-01',
                      width: 100,
                      height: 108,
                      boxFit: BoxFit.cover,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    _buildHeading(),
                    const SizedBox(
                      height: 8,
                    ),
                    _buildSubHeading(),
                    const SizedBox(
                      height: 40,
                    ),
                    _buildPhoneNumberFiled(),
                    _buildContinueButton(),
                    const SizedBox(
                      height: 40,
                    ),
                    Expanded(child: _buildPrivacyPolicyAndTnCContainer()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return BlocConsumer<VerifyPhoneNumberFromAPICubit,
        VerifyPhoneNumberFromAPIState>(
      listener:
          (BuildContext context, VerifyPhoneNumberFromAPIState state) async {
        if (state is VerifyPhoneNumberFromAPIFailure) {
          UiUtils.showMessage(
            context,
            state.errorMessage.translate(context: context),
            MessageType.error,
          );
        }
        if (state is VerifyPhoneNumberFromAPISuccess) {
          //messageCode
          // 101:- Mobile number already registered and Active
          // 102:- Mobile number is not registered
          // 103:- Mobile number is De-active
          //
          final bool isNewUser = widget.screenTitle != 'forgotPassword';
          //

          if (state.error && isNewUser) {
            UiUtils.showMessage(
              context,
              'mobileAlreadyRegistered'.translate(context: context),
              MessageType.error,
            );
          } else if (state.messageCode == '102' && !isNewUser) {
            UiUtils.showMessage(
              context,
              'mobileNumberIsNotRegistered'.translate(context: context),
              MessageType.error,
            );
          } else if (state.messageCode == '103' && !isNewUser) {
            UiUtils.showMessage(
              context,
              'mobileNumberIsDeactivate'.translate(context: context),
              MessageType.error,
            );
          } else {
            context.read<VerifyPhoneNumberCubit>().verifyPhoneNumber(
              phoneNumberWithCountryCode,
              onCodeSent: () {
                'codeHasBeenSentToYourMobileNumber'.translate(context: context);
              },
            );
          }
        }
        //
      },
      builder: (BuildContext context, VerifyPhoneNumberFromAPIState state) {
        Widget? child;
        if (state is VerifyPhoneNumberFromAPIInProgress) {
          child = CircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        } else if (state is SendVerificationCodeInProgress) {
          child = null;
        }

        return BlocConsumer<VerifyPhoneNumberCubit, VerifyPhoneNumberState>(
          listener: (
            BuildContext context,
            VerifyPhoneNumberState verifyPhoneNumberState,
          ) {
            if (verifyPhoneNumberState is SendVerificationCodeInProgress) {
              context.read<VerifyPhoneNumberCubit>().setInitialState();

              //
              Navigator.pushNamed(
                context,
                Routes.otpVerificationRoute,
                arguments: {
                  'phoneNumberWithCountryCode': phoneNumberWithCountryCode,
                  'phoneNumberWithOutCountryCode': onlyPhoneNumber,
                  'countryCode':
                      context.read<CountryCodeCubit>().getSelectedCountryCode(),
                  'isItForForgotPassword':
                      widget.screenTitle == 'forgotPassword'
                },
              );
            } else if (verifyPhoneNumberState
                is PhoneNumberVerificationFailure) {
              String errorMessage = '';

              errorMessage = verifyPhoneNumberState.error.code
                  .toString()
                  .getFirebaseError(context: context);
              UiUtils.showMessage(context, errorMessage, MessageType.error);
            }
          },
          builder: (
            BuildContext context,
            VerifyPhoneNumberState verifyPhoneNumberState,
          ) {
            if (verifyPhoneNumberState is PhoneNumberVerificationInProgress) {
              child = CircularProgressIndicator(
                color: AppColors.whiteColors,
              );
            }
            if ((verifyPhoneNumberState is SendVerificationCodeInProgress ||
                    verifyPhoneNumberState is PhoneNumberVerificationFailure ||
                    verifyPhoneNumberState is VerifyPhoneNumberInitial) &&
                state is! VerifyPhoneNumberFromAPIInProgress) {
              child = null;
            }
            return CustomRoundedButton(
              height: 50,
              onTap: () async {
                if (verifyPhoneNumberState
                    is PhoneNumberVerificationInProgress) {
                  return;
                }
                _onContinueButtonClicked();
              },
              buttonTitle: 'continue'.translate(context: context),
              widthPercentage: 0.9,
              backgroundColor: Theme.of(context).colorScheme.accentColor,
              showBorder: false,
              child: child,
            );
          },
        );
      },
    );
  }

  Align _buildPrivacyPolicyAndTnCContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'byContinueYouAccept'.translate(context: context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.lightGreyColor,
              fontSize: 14,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.appSettings,
                      arguments: {'title': 'privacyPolicy'},
                    );
                  },
                  child: Text(
                    'privacyPolicyLbl'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  ' & ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.appSettings,
                      arguments: {'title': 'termsCondition'},
                    );
                  },
                  child: Text(
                    'termsConditionLbl'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
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
    );
  }
}
