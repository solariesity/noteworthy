import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../services/word_service.dart';

class WordProvider extends ChangeNotifier {
  final WordService _wordService;

  WordEntry? _currentWord;
  String? _previousWordText;
  List<WordEntry>? _planWords;
  List<int> _shuffledIndices = [];
  int _planPosition = 0;

  WordProvider(this._wordService);

  WordEntry? get currentWord => _currentWord;
  bool get isLoaded => _currentWord != null;
  List<WordEntry> get allWords => _wordService.allWords;
  bool get isPlanMode => _planWords != null;
  List<WordEntry> get effectiveWords => _planWords ?? _wordService.allWords;

  void selectWord(WordEntry entry) {
    _previousWordText = _currentWord?.word;
    _currentWord = entry;
    notifyListeners();
  }

  void loadPlanWords(List<WordEntry> words) {
    _planWords = words;
    _previousWordText = null;
    if (words.isEmpty) {
      _currentWord = null;
      _shuffledIndices = [];
      _planPosition = 0;
    } else {
      // 打乱索引顺序，每次 nextWord 按序取，一轮结束后重新打乱
      _shuffledIndices = List.generate(words.length, (i) => i)..shuffle(Random());
      _planPosition = 0;
      _currentWord = words[_shuffledIndices[0]];
    }
    notifyListeners();
  }

  void resetToDefault() {
    _planWords = null;
    _shuffledIndices = [];
    _planPosition = 0;
    _previousWordText = null;
    _currentWord = _wordService.randomWord();
    notifyListeners();
  }

  void nextWord() {
    _previousWordText = _currentWord?.word;

    if (_planWords != null && _shuffledIndices.isNotEmpty) {
      _planPosition++;
      if (_planPosition >= _shuffledIndices.length) {
        _shuffledIndices.shuffle(Random());
        _planPosition = 0;
      }
      _currentWord = _planWords![_shuffledIndices[_planPosition]];
    } else {
      _currentWord = _wordService.randomWord(exclude: _previousWordText);
      _planPosition = 0;
    }
    notifyListeners();
  }
}
