// ignore_for_file: file_names

class ErrorFilter {
  ErrorFilter(this.error);
  factory ErrorFilter.check(errorCode) {
    switch (errorCode) {
      case 'network-request-failed':
        return ErrorFilter('Please check internet connection');
      case 'no-internet':
        return ErrorFilter('Please check internet connection');
      case 'email-already-in-use':
        return ErrorFilter('This email is already registerd.');
      case 'wrong-password':
        return ErrorFilter('The password is wrong.');
      case 'user-not-found':
        return ErrorFilter('This email is not registerd. Please try signup.');
      case 'invalid-email':
        return ErrorFilter('This email is not valid.');
      case 'invalid-phone-number':
        return ErrorFilter('Phone number is invalid.');
      case 'invalid-verification-code':
        return ErrorFilter('OTP is incorrect.');
      case 'too-many-requests':
        return ErrorFilter('Unusual activity detected. Please try again later');
      default:
        return ErrorFilter(errorCode);
    }
  }
  final dynamic error;
}
