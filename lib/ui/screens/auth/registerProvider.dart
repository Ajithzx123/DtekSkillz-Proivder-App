import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class ProviderRegistration extends StatefulWidget {

  const ProviderRegistration(
      {super.key,
      required this.mobileNumber,
      required this.countryCode,
      required this.phoneNumberWithOutCountryCode,});
  final String mobileNumber;
  final String phoneNumberWithOutCountryCode;
  final String countryCode;

  @override
  ProviderRegistrationState createState() => ProviderRegistrationState();

  static Route<ProviderRegistration> route(RouteSettings routeSettings) {
    final Map<String, String> parameter = routeSettings.arguments as Map<String, String>;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => RegisterProviderCubit(),
        child: ProviderRegistration(
          mobileNumber: parameter['registeredMobileNumber'].toString(),
          countryCode: parameter['countryCode'].toString(),
          phoneNumberWithOutCountryCode: parameter['phoneNumberWithOutCountryCode'].toString(),
        ),
      ),
    );
  }
}

class ProviderRegistrationState extends State<ProviderRegistration> {
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();

  ///form1
  TextEditingController userNmController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobNoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController companyNmController = TextEditingController();

  FocusNode userNmFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobNoFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode companyNameFocus = FocusNode();

  @override
  void dispose() {
     userNmController.dispose() ;
     emailController.dispose() ;
     mobNoController.dispose() ;
     passwordController.dispose() ;
     confirmPasswordController.dispose() ;
     companyNmController.dispose() ;

     userNmFocus.dispose()  ;
     emailFocus.dispose()  ;
     mobNoFocus.dispose()  ;
     passwordFocus.dispose() ;
     confirmPasswordFocus.dispose() ;
     companyNameFocus.dispose() ;
    super.dispose();
  }
  @override
  void initState() {
    mobNoController.text = widget.mobileNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: CustomText(
          titleText: 'regFormTitle'.translate(context: context),
          fontColor: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.bold,
        ),
        leading: UiUtils.setBackArrow(context),
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            clipBehavior: Clip.none,
            child: Form(
                key: formKey1,
                child: Column(
                  children: [
                    UiUtils.setTitleAndTFF(
                      context,
                      titleText: 'compNmLbl'.translate(context: context),
                      controller: companyNmController,
                      currNode: companyNameFocus,
                      validator: (String? companyName) => Validator.nullCheck(companyName),
                    ),
                    UiUtils.setTitleAndTFF(
                      context,
                      titleText: 'userNmLbl'.translate(context: context),
                      controller: userNmController,
                      currNode: userNmFocus,
                      nextFocus: emailFocus,
                      validator: (String? username) => Validator.nullCheck(username),
                    ),
                    UiUtils.setTitleAndTFF(
                      context,
                      titleText: 'emailLbl'.translate(context: context),
                      controller: emailController,
                      currNode: emailFocus,
                      nextFocus: mobNoFocus,
                      textInputType: TextInputType.emailAddress,
                      validator: (String? email) => Validator.validateEmail(email),
                    ),
                    UiUtils.setTitleAndTFF(context,
                        titleText: 'mobNoLbl'.translate(context: context),
                        controller: mobNoController,
                        currNode: mobNoFocus,
                        nextFocus: passwordFocus,
                        textInputType: TextInputType.phone,
                        isReadOnly: true,),
                    UiUtils.setTitleAndTFF(
                      context,
                      titleText: 'passwordLbl'.translate(context: context),
                      controller: passwordController,
                      currNode: passwordFocus,
                      nextFocus: confirmPasswordFocus,
                      isPswd: true,
                      validator: (String? password) {
                        return Validator.nullCheck(password);
                      },
                    ),
                    UiUtils.setTitleAndTFF(
                      context,
                      titleText: 'confirmPasswordLbl'.translate(context: context),
                      controller: confirmPasswordController,
                      currNode: confirmPasswordFocus,
                      nextFocus: companyNameFocus,
                      isPswd: true,
                      validator: (String? confirmPassword) => Validator.nullCheck(confirmPassword),
                    ),
                    const SizedBox(
                      height: 55,
                    )
                  ],
                ),),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
                right: 15,
                left: 15,
              ),
              child: BlocConsumer<RegisterProviderCubit, RegisterProviderState>(
                listener: (BuildContext context, RegisterProviderState state) {
                  if (state is RegisterProviderSuccess) {
                    Navigator.pushReplacementNamed(context, Routes.successScreen, arguments: {
                      'title': 'registration',
                      'message': 'doLoginAndCompleteKYC',
                      'imageName': 'registration'
                    },);
                  } else if (state is RegisterProviderFailure) {
                    UiUtils.showMessage(
                        context, state.errorMessage.translate(context: context), MessageType.error,);
                  }
                },
                builder: (BuildContext context, RegisterProviderState state) {
                  Widget? child;
                  if (state is RegisterProviderInProgress) {
                    child = CircularProgressIndicator(
                      color: AppColors.whiteColors,
                    );
                  } else if (state is RegisterProviderSuccess || state is RegisterProviderFailure) {
                    child = null;
                  }
                  return CustomRoundedButton(
                    showBorder: false,
                    buttonTitle: 'submitBtnLbl'.translate(context: context),
                    widthPercentage: 1,
                    backgroundColor: Theme.of(context).colorScheme.accentColor,
                    titleColor: Theme.of(context).colorScheme.secondaryColor,
                    child: child,
                    onTap: () {
                      if (state is RegisterProviderInProgress) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      formKey1.currentState?.save();

                      if (formKey1.currentState!.validate()) {
                        if (passwordController.text.trim() !=
                            confirmPasswordController.text.trim()) {
                          UiUtils.showMessage(
                              context,
                              'confirmPasswordDoesNotMatch'.translate(context: context),
                              MessageType.error,);
                          return;
                        }

                        final Map<String, dynamic> parameter = {
                          'company_name': companyNmController.text.trim(),
                          'username': userNmController.text.trim(),
                          'password': passwordController.text.trim(),
                          'password_confirm': passwordController.text.trim(),
                          'email': emailController.text.trim(),
                          'mobile': widget.phoneNumberWithOutCountryCode,
                          'country_code': widget.countryCode,
                        };
                        context
                            .read<RegisterProviderCubit>()
                            .registerProvider(parameter: parameter);
                      }
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
