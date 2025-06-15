class TextFieldValidation {
  static bool passwordValidate(String value) {
    if (value.isEmpty) {
      return false;
    }
    return true;
  }

  static bool confirmPasswordValidate(String value, String password) {
    if ((value.isNotEmpty && value.length >= 8) && (password.isNotEmpty && password.length >= 8)) {
      if (value == password) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static bool emailValidate(String value) {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(value);
  }
}
