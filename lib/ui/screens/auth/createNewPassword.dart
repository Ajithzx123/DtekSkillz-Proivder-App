// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';


class CreateNewPassword extends StatefulWidget {

  const CreateNewPassword({
    super.key,
    required this.phoneNumberWithoutCountryCode,
    required this.countryCode,
  });
  final String phoneNumberWithoutCountryCode;
  final String countryCode;

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();

  static Route route(RouteSettings routeSettings) {
    final Map<String, dynamic> arguments = routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(builder: (_) {
      return BlocProvider<CreateNewPasswordCubit>(
        create: (BuildContext context) => CreateNewPasswordCubit(),
        child: CreateNewPassword(
          countryCode: arguments['countryCode'],
          phoneNumberWithoutCountryCode: arguments['phoneNumberWithOutCountryCode'],
        ),
      );
    },);
  }
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  String phoneNumberWithCountryCode = '';
  String onlyPhoneNumber = '';
  String countryCode = '';

  final GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _confirmNewPasswordController.dispose();
    _newPasswordController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onContinueButtonClicked() {
    UiUtils.removeFocus();

    final bool validateForm = changePasswordFormKey.currentState!.validate();

    if (validateForm) {
      //
      final String newPassword = _newPasswordController.text.trim();
      final String confirmNewPassword = _confirmNewPasswordController.text.trim();

      if (newPassword != confirmNewPassword) {
        UiUtils.showMessage(
            context, 'confirmPasswordDoesNotMatch'.translate(context: context), MessageType.error,);
        return;
      }
      final String countryCode = context.read<CountryCodeCubit>().getSelectedCountryCode();
      //
      context.read<CreateNewPasswordCubit>().createNewPassword(
            countryCode: countryCode,
            mobileNumber: widget.phoneNumberWithoutCountryCode,
            newPassword: confirmNewPassword,
          );
    }
  }

  Widget _buildPasswordFiled(
      {required TextEditingController controller, required String hintText,}) {
    return CustomTextFormField(
      controller: controller,
      isDense: false,
      isRoundedBorder: true,
      backgroundColor: Colors.transparent,
      hintText: hintText.translate(context: context),
      hintTextColor: Theme.of(context).colorScheme.lightGreyColor,
      isPswd: true,
      validator: (String? password) => Validator.nullCheck(password),
    );
  }

  Widget _buildHeading() {
    return Text('createNewPassword'.translate(context: context),
        style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 28.0,),
        textAlign: TextAlign.center,);
  }

  Widget _buildSubHeading() {
    return Text(
        'yourNewPasswordMustBeDifferentFromPreviouslyUsedPassword'.translate(context: context),
        style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor.withOpacity(0.5),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 16.0,),
        textAlign: TextAlign.center,);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          elevation: 1,
          centerTitle: true,
          leading: UiUtils.setBackArrow(context),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: changePasswordFormKey,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(28.0),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      UiUtils.setSVGImage('loginlogo',
                          width: 100, height: 108, boxFit: BoxFit.cover,),
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
                      _buildPasswordFiled(
                          controller: _newPasswordController, hintText: 'newPassword',),
                      const SizedBox(
                        height: 15,
                      ),
                      _buildPasswordFiled(
                          controller: _confirmNewPasswordController,
                          hintText: 'confirmNewPassword',),
                      const SizedBox(
                        height: 40,
                      ),
                      _buildContinueButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return BlocConsumer<CreateNewPasswordCubit, CreateNewPasswordState>(
      listener: (BuildContext context, CreateNewPasswordState state) {
        if (state is CreateNewPasswordFailure) {
          UiUtils.showMessage(
              context, state.errorMessage.translate(context: context), MessageType.error,);
        } else if (state is CreateNewPasswordSuccess) {
          //
          Navigator.pushReplacementNamed(context, Routes.successScreen, arguments: {
            'title': 'resetPasswordSuccessful'.translate(context: context),
            'message': 'youHaveSuccessfullyResetYourPasswordPleaseUseYourNewPasswordWhenLoggingIn'
                .translate(context: context),
            'imageName': 'success'
          },);
        }
      },
      builder: (BuildContext context, CreateNewPasswordState state) {
        Widget? child;
        if (state is CreateNewPasswordInProgress) {
          child = CircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        } else if (state is CreateNewPasswordFailure || state is CreateNewPasswordSuccess) {
          child = null;
        }
        return CustomRoundedButton(
          height: 50,
          onTap: () {
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
  }
}
