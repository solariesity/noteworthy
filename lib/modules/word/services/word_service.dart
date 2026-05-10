import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/word_entry.dart';
import '../data/sample_words.dart';

class WordService {
  final List<WordEntry> _words = [];
  final Random _random = Random();

  List<WordEntry> get allWords => List.unmodifiable(_words);
  int get count => _words.length;

  Future<void> initialize() async {
    try {
      // 尝试加载 assets/data/words.json，文件不存在时回退到 sampleWords
      final jsonString = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _words.addAll(
        jsonList.map((j) => WordEntry.fromJson(j as Map<String, dynamic>)),
      );
    } catch (_) {
      _words.addAll(sampleWords);
    }

    if (_words.isEmpty) {
      _words.addAll(sampleWords);
    }
  }

  WordEntry randomWord({String? exclude}) {
    if (_words.isEmpty) {
      return sampleWords.first;
    }

    if (_words.length == 1) {
      return _words.first;
    }

    final candidates = exclude != null
        ? _words.where((w) => w.word != exclude).toList()
        : _words;

    if (candidates.isEmpty) {
      return _words.first;
    }

    return candidates[_random.nextInt(candidates.length)];
  }
}
