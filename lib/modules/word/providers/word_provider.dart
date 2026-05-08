import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../services/word_service.dart';

class WordProvider extends ChangeNotifier {
  final WordService _wordService;

  WordEntry? _currentWord;
  String? _previousWordText;

  WordProvider(this._wordService);

  WordEntry? get currentWord => _currentWord;
  bool get isLoaded => _currentWord != null;

  void nextWord() {
    _previousWordText = _currentWord?.word;
    _currentWord = _wordService.randomWord(exclude: _previousWordText);
    notifyListeners();
  }
}
