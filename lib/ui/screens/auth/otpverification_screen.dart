// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../app/generalImports.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumberWithCountryCode,
    required this.phoneNumberWithOutCountryCode,
    required this.countryCode,
    required this.isItForForgotPassword,
  });
  final String phoneNumberWithCountryCode;
  final String phoneNumberWithOutCountryCode;
  final String countryCode;
  final bool isItForForgotPassword;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();

  static Route route(RouteSettings routeSettings) {
    final Map parameters = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) {
        return OtpVerificationScreen(
          phoneNumberWithCountryCode: parameters['phoneNumberWithCountryCode'],
          phoneNumberWithOutCountryCode:
              parameters['phoneNumberWithOutCountryCode'],
          countryCode: parameters['countryCode'],
          isItForForgotPassword: parameters['isItForForgotPassword'],
        );
      },
    );
  }
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with CodeAutoFill {
  bool isCountdownFinished = false;
  bool isOtpSent = false;
  TextEditingController otpController = TextEditingController();
  bool shouldShowOtpResendSuccessMessage = false;
  FocusNode otpFiledFocusNode = FocusNode();
  CountDownTimer countDownTimer = CountDownTimer();

  ValueNotifier<bool> isCountDownCompleted = ValueNotifier(false);

  //
  @override
  void codeUpdated() {
    otpController.text = code!;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SmsAutoFill().getAppSignature.then((String signature) {});
    SmsAutoFill().listenForCode();
    countDownTimer.start(() => _onCountdownComplete());
  }

  @override
  void dispose() {
    otpFiledFocusNode.dispose();
    otpController.dispose();
    unregisterListener();
    cancel();
    SmsAutoFill().unregisterListener();
    countDownTimer.timerController.close();
    isCountDownCompleted.dispose();
    super.dispose();
  }

  void _onCountdownComplete() {
    isCountDownCompleted.value = true;
  }

  //
  void _onResendOtpClick() {
    if (isCountDownCompleted.value) {
      context.read<ResendOtpCubit>().resendOtp(
        widget.phoneNumberWithCountryCode,
        onOtpSent: () {
          // context.read<CountDownCubit>().reset();
          otpController.clear();
          isCountdownFinished = false;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        },
      );
    }
  }

  Widget _responseMessages(ResendOtpState resendOtpState) {
    return SizedBox(
      height: 30,
      child: Builder(
        builder: (BuildContext context) {
          if (resendOtpState is ResendOtpSuccess) {
            Future.delayed(const Duration(seconds: 3)).then((value) {
              context.read<ResendOtpCubit>().setDefaultOtpState();
            });
          }

          if (resendOtpState is ResendOtpInProcess) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CupertinoActivityIndicator(radius: 8),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'sending_otp'.translate(context: context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            );
          }

          if (resendOtpState is ResendOtpFail) {
            UiUtils.showMessage(
                context,
                resendOtpState.error.message
                    .toString()
                    .translate(context: context),
                MessageType.error);
          }

          return Visibility(
            visible: resendOtpState is ResendOtpSuccess,
            child: Text(
              'otp_sent'.translate(context: context),
              style: TextStyle(color: Theme.of(context).colorScheme.blackColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Text(
        'otp_verification'.translate(context: context),
        style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubHeading() {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Text(
          "${"enter_verification_code".translate(context: context)}\n${widget.phoneNumberWithCountryCode}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 16.0,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  BlocConsumer<VerifyOtpCubit, VerifyOtpState> _buildResendButton(
      BuildContext context, resendOtpState) {
    return BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
      listener: (BuildContext context, VerifyOtpState verifyOtpState) {
        if (verifyOtpState is VerifyOtpSuccess) {
          countDownTimer.close();
          //
          UiUtils.showMessage(context, 'verified'.translate(context: context),
              MessageType.success);
          //
          if (widget.isItForForgotPassword) {
            Navigator.pushReplacementNamed(
              context,
              Routes.createNewPassword,
              arguments: {
                'countryCode': widget.countryCode,
                'phoneNumberWithOutCountryCode':
                    widget.phoneNumberWithOutCountryCode
              },
            );
            //
            return;
          }
          //
          Navigator.pushReplacementNamed(
            context,
            Routes.providerRegistration,
            arguments: {
              'registeredMobileNumber': widget.phoneNumberWithCountryCode,
              'countryCode': widget.countryCode,
              'phoneNumberWithOutCountryCode':
                  widget.phoneNumberWithOutCountryCode
            },
          );
          //
        } else if (verifyOtpState is VerifyOtpFail) {
          Future.delayed(const Duration(seconds: 3), () {
            context.read<VerifyOtpCubit>().setInitialState();
          });
          //
          String errorMessage = '';
          errorMessage = verifyOtpState.error.code
              .toString()
              .getFirebaseError(context: context);
          //
          Future.delayed(Duration.zero, () {
            otpController.clear();
          });
          //
          UiUtils.showMessage(context, errorMessage, MessageType.error);
        }
      },
      builder: (BuildContext context, VerifyOtpState verifyOtpState) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 42, minWidth: 130),
          child: OutlinedButton(
            onPressed: _onResendOtpClick,
            style: _resendButtonStyle(),
            child: ValueListenableBuilder(
              valueListenable: isCountDownCompleted,
              builder: (BuildContext context, Object? value, Widget? child) {
                return isCountDownCompleted.value
                    ? Text(
                        'resend_otp'.translate(context: context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : _resendCountDownButton();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _resendCountDownButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'resend_otp_in'.translate(context: context),
          style: TextStyle(
            color: Theme.of(context).colorScheme.lightGreyColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 18.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          width: 3,
        ),
        countDownTimer.listenText(
            color: Theme.of(context).colorScheme.lightGreyColor)
      ],
    );
  }

  ButtonStyle _resendButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor:
          MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Theme.of(context).colorScheme.lightGreyColor;
        }
        return Theme.of(context).colorScheme.blackColor;
      }),
      side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return BorderSide(
              color: Theme.of(context).colorScheme.lightGreyColor);
        } else {
          return BorderSide(color: Theme.of(context).colorScheme.blackColor);
        }
      }),
    );
  }

  Widget _buildOtpField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: PinFieldAutoFill(
            currentCode: '',
            controller: otpController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
            ],
            focusNode: otpFiledFocusNode,
            decoration: BoxLooseDecoration(
              gapSpace: 10,
              hintText: '123456',
              textStyle:
                  TextStyle(color: Theme.of(context).colorScheme.blackColor),
              hintTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.lightGreyColor),
              strokeColorBuilder: PinListenColorBuilder(
                Theme.of(context).colorScheme.accentColor,
                Theme.of(context).colorScheme.lightGreyColor,
              ),
            ),
            onCodeChanged: (String? otpValue) {
              if (otpValue!.length == 6) {
                context.read<VerifyOtpCubit>().verifyOtp(otpValue);
                otpFiledFocusNode.unfocus();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        elevation: 1,
        centerTitle: true,
        leading: UiUtils.setBackArrow(context),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 30, 20, 20),
        child: BlocConsumer<ResendOtpCubit, ResendOtpState>(
          listener: (BuildContext context, ResendOtpState state) {
            if (state is ResendOtpSuccess) {
              isCountDownCompleted.value = false;
              //
              countDownTimer.start(() => _onCountdownComplete());
              //
              context.read<ResendOtpCubit>().setDefaultOtpState();
            }
          },
          builder: (BuildContext context, ResendOtpState resendOtpState) {
            return SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    UiUtils.setSVGImage('logo_partner_casdd-01',
                        width: 100, height: 108, boxFit: BoxFit.cover),
                    const SizedBox(
                      height: 40,
                    ),
                    _buildHeader(),
                    _buildSubHeading(),
                    _buildOtpField(context),
                    if (context.watch<VerifyOtpCubit>().state
                        is VerifyOtpInProcess) ...[
                      _buildOTPVerificationStatus(context)
                    ] else ...[
                      _responseMessages(resendOtpState),
                    ],
                    _buildResendButton(context, resendOtpState),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOTPVerificationStatus(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Builder(
        builder: (BuildContext context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(radius: 8),
              const SizedBox(
                width: 5,
              ),
              Text('otpVerifying'.translate(context: context))
            ],
          );
        },
      ),
    );
  }
}
