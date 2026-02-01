class MethodName {
  static const String NATIVE_ALERT = "NATIVE_ALERT";

  static const String NATIVE_ACTION_SHEET = "NATIVE_ACTION_SHEET";

  static const String NATIVE_TAB_BAR = "NATIVE_TAB_BAR";

  static const String NATIVE_APP_BAR = "NATIVE_APP_BAR";
}

extension MethodNameExtension on String {
  String withId(int id) => "$this/$id";
}
