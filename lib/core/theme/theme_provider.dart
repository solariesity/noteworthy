import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThemeAccent {
  final String name;
  final Color color;

  const ThemeAccent(this.name, this.color);
}

const themeAccents = [
  ThemeAccent('靛蓝', Color(0xFF5C6BC0)),
  ThemeAccent('青蓝', Color(0xFF2196F3)),
  ThemeAccent('青绿', Color(0xFF009688)),
  ThemeAccent('翠绿', Color(0xFF4CAF50)),
  ThemeAccent('琥珀', Color(0xFFFF9800)),
  ThemeAccent('珊瑚', Color(0xFFFF7043)),
  ThemeAccent('玫红', Color(0xFFE91E63)),
  ThemeAccent('紫罗兰', Color(0xFF9C27B0)),
];

class ThemeProvider extends ChangeNotifier {
  Color _accentColor = themeAccents[0].color;
  int _index = 0;

  Color get accentColor => _accentColor;
  int get selectedIndex => _index;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/theme.json');
      if (await file.exists()) {
        final map = json.decode(await file.readAsString()) as Map<String, dynamic>;
        _index = map['index'] as int? ?? 0;
        _accentColor = themeAccents[_index.clamp(0, themeAccents.length - 1)].color;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> selectAccent(int index) async {
    if (index < 0 || index >= themeAccents.length) return;
    _index = index;
    _accentColor = themeAccents[index].color;
    notifyListeners();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/theme.json');
      await file.writeAsString(json.encode({'index': index}));
    } catch (_) {}
  }
}
