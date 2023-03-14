/// Represents a class for configuration of the system.
class Config {
  /// The class is implemented as a singleton, with a private constructor and a private static instance variable _instance.
  static final Config _instance = Config._();

  /// Url for HTTP APIs
  String baseUrl = "";

  /// Url for realtime communication
  String baseUrlWebSocket = "";

  /// The factory constructor returns the single instance stored in _instance.
  factory Config() => _instance;

  Config._();
}
