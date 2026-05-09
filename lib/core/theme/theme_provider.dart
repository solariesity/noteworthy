import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThemeAccent {
  final String name;
  final Color color;
  final Brightness brightness;
  final IconData icon;

  const ThemeAccent(this.name, this.color, this.brightness, this.icon);
}

const themeAccents = [
  ThemeAccent('天际', Color(0xFF42A5F5), Brightness.light, Icons.wb_sunny),
  ThemeAccent('嫩绿', Color(0xFF66BB6A), Brightness.light, Icons.eco),
  ThemeAccent('琥珀', Color(0xFFFFA726), Brightness.light, Icons.wb_twilight),
  ThemeAccent('珊瑚', Color(0xFFFF7043), Brightness.light, Icons.favorite),
  ThemeAccent('丁香', Color(0xFFAB47BC), Brightness.light, Icons.auto_awesome),
  ThemeAccent('青碧', Color(0xFF26A69A), Brightness.light, Icons.water_drop),
  ThemeAccent('蜜橙', Color(0xFFFFB74D), Brightness.light, Icons.local_fire_department),
  ThemeAccent('薄雾', Color(0xFF90A4AE), Brightness.light, Icons.cloud),
  ThemeAccent('岩灰', Color(0xFF8D6E63), Brightness.light, Icons.terrain),
  ThemeAccent('桃色', Color(0xFFFFAB91), Brightness.light, Icons.spa),
  ThemeAccent('靛蓝', Color(0xFF5C6BC0), Brightness.dark, Icons.dark_mode),
  ThemeAccent('紫罗兰', Color(0xFF9C27B0), Brightness.dark, Icons.nightlight),
];

class ThemeProvider extends ChangeNotifier {
  Color _accentColor = themeAccents[0].color;
  Brightness _brightness = themeAccents[0].brightness;
  int _index = 0;

  Color get accentColor => _accentColor;
  Brightness get brightness => _brightness;
  int get selectedIndex => _index;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/theme.json');
      if (await file.exists()) {
        final map = json.decode(await file.readAsString()) as Map<String, dynamic>;
        _index = map['index'] as int? ?? 0;
        _updateSelection();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> selectAccent(int index) async {
    if (index < 0 || index >= themeAccents.length) return;
    _index = index;
    _updateSelection();
    notifyListeners();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/theme.json');
      await file.writeAsString(json.encode({'index': index}));
    } catch (_) {}
  }

  void _updateSelection() {
    final clamped = _index.clamp(0, themeAccents.length - 1);
    _accentColor = themeAccents[clamped].color;
    _brightness = themeAccents[clamped].brightness;
  }
}
