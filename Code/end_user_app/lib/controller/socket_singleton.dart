import 'package:end_user_app/config/config.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

///This is a Dart style implementation of the Singleton pattern for creating a WebSocket connection using the socket.io library.
///
///The class SocketSingleton has a static final instance _singleton and a late instance _socket of type IO.Socket.
class SocketSingleton {
  static final SocketSingleton _singleton = SocketSingleton._internal();
  late IO.Socket _socket;

  /// The class has a factory constructor that returns the singleton instance.
  ///
  /// The singleton instance is created in the private constructor SocketSingleton._internal().
  factory SocketSingleton() {
    return _singleton;
  }

  /// The class has a factory constructor that returns the singleton instance. The singleton instance is created in the private constructor SocketSingleton._internal().
  ///
  /// In the constructor, the _socket instance is created using the IO.io function, connecting to Config.baseUrlWebSocket and with the transports and autoConnect options set. An event listener is then added to the socket, listening for a connect event and printing a message to the console.
  SocketSingleton._internal() {
    _socket = IO.io(Config().baseUrlWebSocket, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    // ignore: avoid_print
    socket.on('connect', (_) => print("connected to socket"));
  }

  IO.Socket get socket {
    return _socket;
  }
}
