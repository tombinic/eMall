/// Represent a class to handle and store http requests.
// ignore_for_file: unnecessary_getters_setters

class ApiResponse {
  /// _data will hold any response converted into
  /// its own object. For example user.
  late Object _data;

  /// _apiError will hold the error object.
  String _error = "";

  // ignore: non_constant_identifier_names
  Object get Data => _data;
  // ignore: non_constant_identifier_names
  set Data(Object data) => _data = data;

  // ignore: non_constant_identifier_names
  String get ApiError => _error;
  // ignore: non_constant_identifier_names
  set ApiError(String error) => _error = error;
}
