import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:rxdart/subjects.dart';
import 'package:web_socket_channel/io.dart';

class FoxbitWebSocket {
  late IOWebSocketChannel _socket;
  int _id = 0;
  bool _connectedByUser = false;
  bool connected = false;

  final int _idStepSize = 2;

  @protected
  final BehaviorSubject<Map> streamController = BehaviorSubject<Map>();

  int get lastId => _id - _idStepSize;

  FoxbitWebSocket() {
    _socket = IOWebSocketChannel.connect('api.foxbit.com.br?origin=android');
  }

  void connect() {
_socket = IOWebSocketChannel.connect(
      Uri.parse('api.foxbit.com.br?origin=android'),
    );
    _connectedByUser = true;
       _socket.stream.listen(
      onMessage,
      onDone: _onDone,
      cancelOnError: false,
    );
    connected = true;
    _id = 0;
  }

  Future<void> disconnect() async {
    _connectedByUser = false;
    connected = false;
    await _socket.sink.close();
  }

  void send(String method, dynamic data) {
     _socket.sink.add(prepareMessage(method, data));
  }

  Stream<Map> get stream => streamController.stream;

  @protected
  String prepareMessage(String method, dynamic objectData) {
    final Map data = {
      "m": 0,
      "i": _id,
      "n": method,
      "o": json.encode(objectData)
    };

    _id += _idStepSize;

    return json.encode(data);
  }

  @protected
  void onMessage(dynamic message) {
    final Map data = json.decode(message.toString()) as Map;

    if (data['o'].toString().isNotEmpty) {
      data['o'] = json.decode(data['o'].toString());
    }

    streamController.add(data);
  }

  void _onDone() {
    if (_connectedByUser) {
      _reconnect();
    }
  }

  void _reconnect() {
    Timer(const Duration(seconds: 1), () async {
      connect();
    });
  }
}
