import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/plan_storage.dart';

class FavoritesProvider extends ChangeNotifier {
  final PlanStorage _planStorage;
  Set<String> _favoriteWords = {};

  FavoritesProvider(this._planStorage);

  Set<String> get favoriteWords => _favoriteWords;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/favorites.json');
      if (await file.exists()) {
        final list = json.decode(await file.readAsString()) as List<dynamic>;
        _favoriteWords = list.map((e) => e as String).toSet();
      } else {
        // 迁移旧数据：从「收藏词汇」计划中提取
        await _migrateFromLegacyPlan();
      }
    } catch (_) {
      await _migrateFromLegacyPlan();
    }
    notifyListeners();
  }

  Future<void> _migrateFromLegacyPlan() async {
    try {
      final index = await _planStorage.loadIndex();
      final fav = index.where((p) => p.name == '收藏词汇').firstOrNull;
      if (fav == null) return;
      final plan = await _planStorage.loadPlan(fav.id);
      if (plan != null && plan.words.isNotEmpty) {
        _favoriteWords = plan.words.map((w) => w.word).toSet();
        await _save();
      }
    } catch (_) {}
  }

  bool isFavorited(String word) => _favoriteWords.contains(word);

  Future<void> toggleFavorite(String word) async {
    if (_favoriteWords.contains(word)) {
      _favoriteWords.remove(word);
    } else {
      _favoriteWords.add(word);
    }
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/favorites.json');
      await file.writeAsString(json.encode(_favoriteWords.toList()));
    } catch (_) {}
  }
}
