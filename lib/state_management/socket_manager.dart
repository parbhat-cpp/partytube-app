import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager extends Cubit<IO.Socket> {
  SocketManager()
      : super(IO.io(dotenv.env['SOCKET_URL'], <String, dynamic>{
          'autoConnect': false,
          'transports': ['websocket'],
        }));

  late bool isConnected;

  void connect(context) {
    state.connect();

    state.onConnect((data) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Server connected'),
      ));
    });

    state.onConnectError((data) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to connect server'),
      ));
    });

    state.onError((data) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to connect server'),
      ));
    });
  }

  void disconnect() {
    state.disconnect();
  }

  void socketEmit(String event, dynamic data) {
    state.emit(event, data);
  }

  void socketListen(String event, Function(dynamic) callback) {
    state.on(event, callback);
  }

  void removeListener(String event) {
    state.off(event);
  }
}
