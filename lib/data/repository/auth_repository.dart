import 'package:edemand_partner/cubits/updateFCMCubit.dart';

import '../../app/generalImports.dart';
import '../../utils/appQuickActions.dart';

class AuthRepository {
  static String? kPhoneNumber;
  static String? verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    Function(dynamic err)? onError,
    VoidCallback? onCodeSent,
  }) async {
    kPhoneNumber = phoneNumber;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential complete) {},
      verificationFailed: (FirebaseAuthException err) {
        onError?.call(err);
      },
      codeSent: (String verification, int? forceResendingToken) {
        verificationId = verification;
        // this is force resending token
        Hive.box(HiveKeys.authBox).put('resendToken', forceResendingToken);
        if (onCodeSent != null) {
          onCodeSent();
        }
      },
      forceResendingToken: Hive.box(HiveKeys.authBox).get('resendToken'),
      codeAutoRetrievalTimeout: (String timeout) {},
    );

    //  confirmation = confirmationResult;
  }

  Future<void> verifyOtp({
    required String code,
    required Function(UserCredential credential) onVerificationSuccess,
  }) async {
    if (verificationId != null) {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: code);

      await _auth
          .signInWithCredential(credential)
          .then((UserCredential credential) {
        onVerificationSuccess(credential);
      });
    }
  }

  Future<Map<String, dynamic>> verifyUserMobileNumberFromAPI(
      {required String mobileNumber, required String countryCode}) async {
    try {
      final Map<String, dynamic> parameter = {
        Api.mobile: mobileNumber,
        Api.countryCode: countryCode
      };

      final Map<String, dynamic> response = await Api.post(
          parameter: parameter, url: Api.verifyUser, useAuthToken: false);

      return {
        'error': response['error'],
        'message': response['message'] ?? '',
        'messageCode': response['message_code'] ?? ''
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String phoneNumber,
    required String password,
    required String countryCode,
  }) async {
    final Map<String, dynamic> parameters = {
      Api.mobile: phoneNumber,
      Api.password: password,
      Api.countryCode: countryCode
    };
    final Map<String, dynamic> response = await Api.post(
      url: Api.loginApi,
      parameter: parameters,
      useAuthToken: false,
    );

//store locally for later use
    if (response['token'] != null) {
      HiveUtils.setJWT(response['token']);
      HiveUtils.setUserData(response['data']);
    }

    if (response['data'] == null) {
      return {
        'userDetails': null,
        'error': true,
        'message': response['message'] ?? ''
      };
    }

    return {
      'userDetails': ProviderDetails.fromJson(response['data'] ?? {}),
      'error': response['error'] ?? false,
      'message': response['message'] ?? ''
    };
  }

  Future logout(BuildContext context) async {
    await HiveUtils.logoutUser(
      onLogout: () async {
        //

        //
        NotificationService.disposeListeners();
        AppQuickActions.clearShortcutItems();
        //
        //This is for remove all other routes from history.
        Navigator.of(context).popUntil((Route route) => route.isFirst);
        Navigator.pushReplacementNamed(context, Routes.loginScreenRoute);
      },
    );
    Future.delayed(
      Duration.zero,
      () {
        context.read<AuthenticationCubit>().setUnAuthenticated();
      },
    );
  }

  //Delete user account
  Future deleteUserAccount() async {
    await Api.post(
        url: Api.deleteUserAccount, parameter: {}, useAuthToken: true);
  }

  //register Provider
  Future<Map<String, dynamic>> registerProvider({
    required Map<String, dynamic> parameters,
    required bool isAuthTokenRequired,
  }) async {
    try {
      //

      //
      final Map<String, dynamic> response = await Api.post(
        //AAA
        // url: Api.registerProvider,
        url: Api.registerProvider,
        parameter: parameters,
        useAuthToken: isAuthTokenRequired,
      );

      if (response['error']) {
        throw ApiException(response["message"].toString());
      }

      return {
        'providerDetails':
            response['data'] != null && (response['data'] as Map).isNotEmpty
                ? ProviderDetails.fromJson(Map.from(response['data']))
                : ProviderDetails(),
        'message': response['message'],
        'error': response['error'],
      };
    } catch (e) {
      return {
        'message': e.toString(),
        'error': true,
        'providerDetails': ProviderDetails()
      };
    }
  }

  //change Password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final Map<String, dynamic> parameters = {
        Api.oldPassword: oldPassword,
        Api.newPassword: newPassword,
      };
      final Map<String, dynamic> response = await Api.post(
        url: Api.changePassword,
        parameter: parameters,
        useAuthToken: true,
      );
      return {
        'message': response['message'],
        'error': response['error'],
      };
    } catch (e) {
      return {
        'message': e.toString(),
        'error': true,
      };
    }
  }

  //create New Password
  Future<Map<String, dynamic>> createNewPassword({
    required String countryCode,
    required String newPassword,
    required String mobileNumber,
  }) async {
    try {
      //
      final Map<String, dynamic> parameters = {
        Api.countryCode: countryCode,
        Api.mobileNumber: mobileNumber,
        Api.newPasswords: newPassword,
      };
      //
      final Map<String, dynamic> response = await Api.post(
        url: Api.createNewPassword,
        parameter: parameters,
        useAuthToken: false,
      );
      //
      return {
        'message': response['message'],
        'error': response['error'],
      };
    } catch (e) {
      //
      return {
        'message': e.toString(),
        'error': true,
      };
    }
  }
}
