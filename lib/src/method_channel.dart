import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:yaru_window_platform_interface/src/platform_interface.dart';
import 'package:yaru_window_platform_interface/src/state.dart';

class YaruWindowMethodChannel extends YaruWindowPlatform {
  @visibleForTesting
  final channel = const MethodChannel('yaru_window');

  @visibleForTesting
  final events = const EventChannel('yaru_window/events');

  @override
  Future<void> init(int id) => _invokeMethod('init', [id]);

  @override
  Future<void> close(int id) => _invokeMethod('close', [id]);
  @override
  Future<void> drag(int id) => _invokeMethod('drag', [id]);
  @override
  Future<void> fullscreen(int id) => _invokeMethod('fullscreen', [id]);
  @override
  Future<void> hide(int id) => _invokeMethod('hide', [id]);
  @override
  Future<void> hideTitle(int id) => _invokeMethod('hideTitle', [id]);
  @override
  Future<void> maximize(int id) => _invokeMethod('maximize', [id]);
  @override
  Future<void> minimize(int id) => _invokeMethod('minimize', [id]);
  @override
  Future<void> restore(int id) => _invokeMethod('restore', [id]);
  @override
  Future<void> show(int id) => _invokeMethod('show', [id]);
  @override
  Future<void> showMenu(int id) => _invokeMethod('showMenu', [id]);
  @override
  Future<void> showTitle(int id) => _invokeMethod('showTitle', [id]);

  @override
  Future<void> setBackground(int id, Color color) =>
      _invokeMethod('setBackground', [id, color.toARGB32()]);
  @override
  Future<void> setBrightness(int id, Brightness brightness) =>
      _invokeMethod('setBrightness', [id, brightness.name]);
  @override
  Future<void> setTitle(int id, String title) =>
      _invokeMethod('setTitle', [id, title]);
  @override
  Future<void> setMinimizable(int id, bool minimizable) =>
      _invokeMethod('setMinimizable', [id, minimizable]);
  @override
  Future<void> setMaximizable(int id, bool maximizable) =>
      _invokeMethod('setMaximizable', [id, maximizable]);
  @override
  Future<void> setClosable(int id, bool closable) =>
      _invokeMethod('setClosable', [id, closable]);

  @override
  Future<void> setControlButtonsVisible(int id, bool visible) =>
      _invokeMethod('setControlButtonsVisible', [id, visible]);
  @override
  Future<void> setResizable(int id, bool resizable) =>
      _invokeMethod('setResizable', [id, resizable]);
  @override
  Future<void> setMinimumSize(int id, Size size) =>
      _invokeMethod('setMinimumSize', [id, size.width, size.height]);
  @override
  Future<void> setMaximumSize(int id, Size size) =>
      _invokeMethod('setMaximumSize', [id, size.width, size.height]);
  @override
  Future<void> setSize(int id, Size size) =>
      _invokeMethod('setSize', [id, size.width, size.height]);
  @override
  Future<void> setPosition(int id, Offset position) =>
      _invokeMethod('setPosition', [id, position.dx, position.dy]);
  @override
  Future<void> center(int id) => _invokeMethod('center', [id]);
  @override
  Future<void> setAlwaysOnTop(int id, bool alwaysOnTop) =>
      _invokeMethod('setAlwaysOnTop', [id, alwaysOnTop]);
  @override
  Future<void> setSkipTaskbar(int id, bool skip) =>
      _invokeMethod('setSkipTaskbar', [id, skip]);

  @override
  Future<YaruWindowState> state(int id) =>
      _invokeMapMethod('state', [id]).then(YaruWindowState.fromJson);
  @override
  Stream<YaruWindowState> states(int id) =>
      _receiveEvents(id, 'state').map(YaruWindowState.fromJson);

  Future<T?> _invokeMethod<T>(String method, [dynamic args]) {
    return channel.invokeMethod<T>(method, args);
  }

  Future<Map<String, dynamic>> _invokeMapMethod(String method, [dynamic args]) {
    return channel
        .invokeMapMethod<String, dynamic>(method, args)
        .then((v) => v!);
  }

  Stream<Map<Object?, Object?>>? _events;
  Stream<Map<String, dynamic>> _receiveEvents(int id, String type) {
    _events ??= events.receiveBroadcastStream().cast<Map<Object?, Object?>>();
    return _events!
        .where((event) => event['id'] == id && event['type'] == type)
        .map((event) => event.cast<String, dynamic>());
  }

  @override
  Future<void> onClose(int id, FutureOr<bool> Function() handler) async {
    WidgetsBinding.instance.addObserver(_YaruWindowObserver(handler));
  }
}

class _YaruWindowObserver with WidgetsBindingObserver {
  _YaruWindowObserver(this.handler);

  final FutureOr<bool> Function() handler;

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    return await handler() ? AppExitResponse.exit : AppExitResponse.cancel;
  }
}
