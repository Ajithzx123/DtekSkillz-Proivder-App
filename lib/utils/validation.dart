class Validator {
  static String? validateNumber(String number) {
    if (number.isEmpty) {
      return 'Field must not be empty';
    } else if (number.length < 6 || number.length > 15) {
      return 'Mobile number should be between 6 and 15 numbers';
    }

    return null;
  }

  static String? nullCheck(String? value, {int? requiredLength}) {
    if (value!.isEmpty) {
      return 'Field must not be empty';
    } else if (requiredLength != null) {
      if (value.length < requiredLength) {
        return 'Text must be $requiredLength character long';
      } else {
        return null;
      }
    }

    return null;
  }

  static String? validateLatitude(String? latitude) {
    if (latitude!.isEmpty) {
      return 'Field must not be empty';
    } else if (!_isLatitudeValid(latitude)) {
      return 'Please enter valid latitude';
    }
    return null;
  }

  static String? validateLongitude(String? longitude) {
    if (longitude!.isEmpty) {
      return 'Field must not be empty';
    } else if (!_isLongitudeValid(longitude)) {
      return 'Please enter valid longitude';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email!.isEmpty) {
      return 'Field must not be empty';
    } else if (!_isValidateEmail(email)) {
      return 'Please enter valid email';
    }
    return null;
  }

  /// Replace extra coma from String
  ///
  static String filterAddressString(String text) {
    const String middleDuplicateComaRegex = ',(.?),';
    const String leadingAndTrailingComa = r'(^,)|(,$)';
    final RegExp removeComaFromString = RegExp(
      middleDuplicateComaRegex,
      caseSensitive: false,
      multiLine: true,
    );

    final RegExp leadingAndTrailing = RegExp(
      leadingAndTrailingComa,
      multiLine: true,
      caseSensitive: false,
    );
    text = text.trim();
    final String filterdText =
        text.replaceAll(removeComaFromString, ',').replaceAll(leadingAndTrailing, '');

    return filterdText;
  }

  static bool _isValidateEmail(String email) {
    final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);

    return emailValid;
  }

  static bool _isLatitudeValid(String latitude) {
    final bool validLatitude = RegExp(r'^-?([0-8]?[0-9]|90)(\.[0-9]{1,10})?$').hasMatch(latitude);

    return validLatitude;
  }

  static bool _isLongitudeValid(String longitude) {
    final bool validLongitude =
        RegExp(r'^-?([0-9]{1,2}|1[0-7][0-9]|180)(\.[0-9]{1,10})?$').hasMatch(longitude);

    return validLongitude;
  }
}
