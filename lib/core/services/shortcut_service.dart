import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

HotKey get _defaultShortcut => HotKey(
      key: LogicalKeyboardKey.keyN,
      modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
    );

class ShortcutService {
  HotKey? _hotKey;
  bool _enabled = false;

  HotKey? get hotKey => _hotKey;
  bool get enabled => _enabled;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/shortcut.json');
      if (await file.exists()) {
        final map = json.decode(await file.readAsString()) as Map<String, dynamic>;
        _enabled = map['enabled'] as bool? ?? false;
        if (map['hotKey'] != null) {
          _hotKey = HotKey.fromJson(map['hotKey'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    // First run: use default Ctrl+Shift+N
    if (_hotKey == null) {
      _hotKey = _defaultShortcut;
      _enabled = true;
    }

    if (_enabled && _hotKey != null) {
      await _register();
      await _save();
    }
  }

  Future<void> setShortcut(HotKey hotKey) async {
    await _unregister();
    _hotKey = hotKey;
    _enabled = true;
    await _register();
    await _save();
  }

  Future<void> clearShortcut() async {
    await _unregister();
    _hotKey = null;
    _enabled = false;
    await _save();
  }

  Future<void> _register() async {
    if (_hotKey == null) return;
    await HotKeyManager.instance.register(
      _hotKey!,
      keyDownHandler: (_) {
        windowManager.show();
        windowManager.focus();
      },
    );
  }

  Future<void> _unregister() async {
    if (_hotKey != null) {
      await HotKeyManager.instance.unregister(_hotKey!);
    }
  }

  Future<void> _save() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/shortcut.json');
      await file.writeAsString(json.encode({
        'enabled': _enabled,
        if (_hotKey != null) 'hotKey': _hotKey!.toJson(),
      }));
    } catch (_) {}
  }
}
