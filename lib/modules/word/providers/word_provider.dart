import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../services/word_service.dart';

class WordProvider extends ChangeNotifier {
  final WordService _wordService;

  WordEntry? _currentWord;
  String? _previousWordText;
  int _planIndex = -1;
  List<WordEntry>? _planWords;

  WordProvider(this._wordService);

  WordEntry? get currentWord => _currentWord;
  bool get isLoaded => _currentWord != null;
  List<WordEntry> get allWords => _wordService.allWords;
  bool get isPlanMode => _planWords != null;

  void selectWord(WordEntry entry) {
    _previousWordText = _currentWord?.word;
    _currentWord = entry;
    notifyListeners();
  }

  void loadPlanWords(List<WordEntry> words) {
    _planWords = words;
    _planIndex = 0;
    _previousWordText = null;
    _currentWord = words.isNotEmpty ? words.first : null;
    notifyListeners();
  }

  void resetToDefault() {
    _planWords = null;
    _planIndex = -1;
    _previousWordText = null;
    _currentWord = _wordService.randomWord();
    notifyListeners();
  }

  void nextWord() {
    _previousWordText = _currentWord?.word;

    if (_planWords != null) {
      _planIndex++;
      if (_planIndex >= _planWords!.length) {
        _planIndex = 0;
      }
      _currentWord = _planWords![_planIndex];
    } else {
      _currentWord = _wordService.randomWord(exclude: _previousWordText);
      _planIndex = -1;
    }
    notifyListeners();
  }

  void moveToNextInPlan() {
    if (_planWords == null) {
      nextWord();
      return;
    }
    _previousWordText = _currentWord?.word;
    _planIndex++;
    if (_planIndex >= _planWords!.length) {
      _planIndex = 0;
    }
    _currentWord = _planWords![_planIndex];
    notifyListeners();
  }
}
