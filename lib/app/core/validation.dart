import '../localization/language_constant.dart';

class Validations {
  static String? name(String? value) {
    if (value!.isEmpty) {
      return getTranslated("please_enter_your_name");
    } else {
      return null;
    }
  }

  static String? mail(String? email) {
    if (email == null || email.length < 8 || !email.contains("@")
        // ||
        // !email.contains(".com"
        // )
        ) {
      return getTranslated("please_enter_valid_email");
    } else {
      return null;
    }
  }

  static String? password(String? password) {
    RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    if (!regex.hasMatch(password ?? "")) {
      // if (password?.trim() == null || password!.isEmpty) {
      return getTranslated("please_enter_valid_password");
    } else {
      return null;
    }
  }

  static String? firstPassword(String? password) {
    RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    if (!regex.hasMatch(password ?? "")) {
      // if (password?.trim() == null || password!.isEmpty) {
      return getTranslated("please_enter_valid_password");
    } else {
      return null;
    }
  }

  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return getTranslated("please_enter_valid_confirm_password");
    } else if (confirmPassword.length < 8) {
      return getTranslated("please_enter_valid_password");
    } else if (password != null) {
      if (password != confirmPassword) {
        return getTranslated("confirm_password_match_validation");
      }
    }
    return null;
  }

  static String? newPassword(String? currentPassword, String? newPassword) {
    if (newPassword == null || newPassword.isEmpty) {
      return getTranslated("please_enter_valid_new_password");
    } else if (newPassword.length < 8) {
      return getTranslated("password_length_validation");
    } else if (currentPassword != null) {
      if (currentPassword == newPassword) {
        return getTranslated("new_password_match_validation");
      }
    }
    return null;
  }

  static String? confirmNewPassword(String? password, String? confirmPassword) {
    if (confirmPassword!.isEmpty) {
      return getTranslated("please_enter_valid_confirm_password");
    } else if (confirmPassword.length < 8) {
      return getTranslated("password_length_validation");
    } else if (password != null) {
      if (password != confirmPassword) {
        return getTranslated("confirm_new_password_match_validation");
      }
    }
    return null;
  }

  static String? phone(String? value) {
    if (value!.isEmpty || value.length < 8) {
      return getTranslated("please_enter_valid_number");
    } else {
      return null;
    }
  }

  static String? year(String? value) {
    if (value == null || value.isEmpty) {
      return "${getTranslated("required_enter")}${getTranslated("year")}";
    } else if (int.parse(value) < 1900 || int.parse(value) > DateTime.now().year) {
      return getTranslated("oops_please_enter_valid_year");
    } else {
      return null;
    }
  }

  static String? field(dynamic value, {String? fieldName, int length = 1}) {
    if (value == null || (value is String && value.isEmpty) || value == "" || value.toString().length < (length)) {
      return "${getTranslated(fieldName != null ? "required_enter" : "required")}${fieldName ?? ""}";
    } else {
      return null;
    }
  }

  static String? iban(String? value) {
    final RegExp ibanRegExp = RegExp(
      r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$',
    );
    if (value == null || value.isEmpty) {
      return "${getTranslated("required_enter")} ${getTranslated("iban")}";
    }
    if (!ibanRegExp.hasMatch(value)) {
      return getTranslated("iban_format_validation");
    }
    if (value.length < 15 || value.length > 34) {
      return getTranslated("iban_length_validation");
    }
    return null;
  }

  static String? link(String? value) {
    final pattern = r'^(https?:\/\/)?((([a-zA-Z0-9$_.+!*\(),;?&=-]+)\.)+[a-zA-Z]{2,})';

    final regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return getTranslated("enter_business_link");
    } else if (!regExp.hasMatch(value)) {
      return getTranslated("enter_valid_link");
    }
    return null;
  }

  static String? code(String? value) {
    if (value == null || value.length < 5) {
      return getTranslated("please_enter_valid_code");
    } else {
      return null;
    }
  }

  static String? city(String? value) {
    if (value!.toString().isEmpty) {
      return getTranslated("please_choose_city");
    } else {
      return null;
    }
  }

  static String? country(String? value) {
    if (value!.toString().isEmpty) {
      return getTranslated("oops_please_select_your_country");
    } else {
      return null;
    }
  }

  static String? area(String? value) {
    if (value!.toString().isEmpty) {
      return getTranslated("please_choose_area");
    } else {
      return null;
    }
  }

  static String? feedBack(String? value) {
    if (value == null || value.length < 4) {
      return getTranslated("please_enter_your_feedback");
    } else {
      return null;
    }
  }

  static String? minValidation(String? value, String? maxValue, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return "${getTranslated("required_enter")}$fieldName";
    } else if (maxValue != null && double.parse(value) >= double.parse(maxValue)) {
      return getTranslated("oops_min_must_be_less_than_max_height");
    } else {
      return null;
    }
  }

  static String? maxValidation(String? value, String? maxValue, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return "${getTranslated("required_enter")}$fieldName";
    } else if (maxValue != null && double.parse(value) <= double.parse(maxValue)) {
      return getTranslated("oops_max_must_be_more_than_min_height");
    } else {
      return null;
    }
  }

  static String? bankAccountName(String? value) {
    List<String> words = value?.trim().split(RegExp(r'\s+')) ?? [];

    if (value == null || value.length < 4 || words.length < 4) {
      return "${getTranslated("required_enter")}${getTranslated("account_owner_name")}";
    } else {
      return null;
    }
  }
}
