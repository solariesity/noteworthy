import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../midi/services/midi_scheduler.dart';

enum IntervalPlayState { idle, playingA, playingB, answered }

class IntervalPracticeProvider extends ChangeNotifier {
  final MidiScheduler _scheduler;

  int? _noteA;
  int? _noteB;
  IntervalPlayState _state = IntervalPlayState.idle;
  String? _selectedAnswer;
  bool _hasPlayed = false;

  IntervalPracticeProvider(this._scheduler);

  static const _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  int? get noteA => _noteA;
  int? get noteB => _noteB;
  IntervalPlayState get state => _state;
  String? get selectedAnswer => _selectedAnswer;
  bool get hasPlayed => _hasPlayed;
  bool get isPlaying =>
      _state == IntervalPlayState.playingA ||
      _state == IntervalPlayState.playingB;
  bool get hasAnswered => _state == IntervalPlayState.answered;

  bool get isCorrect => _selectedAnswer != null &&
      _noteB != null &&
      _selectedAnswer == noteDisplay(_noteB!);

  String get answerDisplay => _noteB != null ? noteDisplay(_noteB!) : '';

  static String noteDisplay(int note) {
    final name = _noteNames[note % 12];
    final octave = (note ~/ 12) - 1;
    return '$name$octave';
  }

  void nextQuestion() {
    final random = Random();
    _noteA = 48 + random.nextInt(25); // 48-72
    do {
      final offset = random.nextInt(25) - 12; // -12 to +12
      _noteB = (_noteA! + offset).clamp(36, 84);
    } while (_noteB == _noteA);

    _selectedAnswer = null;
    _hasPlayed = false;
    _state = IntervalPlayState.idle;
    notifyListeners();
  }

  Future<void> playSequence() async {
    if (_noteA == null || _noteB == null || isPlaying) return;

    _selectedAnswer = null;
    _hasPlayed = true;
    _state = IntervalPlayState.playingA;
    notifyListeners();

    _scheduler.playChord([_noteA!], durationMs: 1200);
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_state != IntervalPlayState.playingA) return;

    _state = IntervalPlayState.playingB;
    notifyListeners();

    _scheduler.playChord([_noteB!], durationMs: 1500);
    await Future.delayed(const Duration(milliseconds: 1800));

    if (_state == IntervalPlayState.playingB) {
      _state = IntervalPlayState.idle;
      notifyListeners();
    }
  }

  void submitAnswer(String answer) {
    if (hasAnswered || isPlaying || !_hasPlayed) return;
    _selectedAnswer = answer;
    _state = IntervalPlayState.answered;
    notifyListeners();
  }
}
