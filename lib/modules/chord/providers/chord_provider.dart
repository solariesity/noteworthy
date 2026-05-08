import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chord_instance.dart';
import '../services/chord_generator.dart';
import '../../../midi/services/midi_scheduler.dart';

enum ChordPlayState { idle, playing, answered }

class ChordProvider extends ChangeNotifier {
  final ChordGenerator _generator;
  final MidiScheduler _scheduler;

  ChordInstance? _currentChord;
  ChordPlayState _state = ChordPlayState.idle;
  String? _selectedAnswer;
  Timer? _debounceTimer;

  ChordProvider(this._generator, this._scheduler);

  ChordInstance? get currentChord => _currentChord;
  ChordPlayState get state => _state;
  String? get selectedAnswer => _selectedAnswer;
  bool get isPlaying => _state == ChordPlayState.playing;
  bool get hasAnswered => _state == ChordPlayState.answered;
  bool get isCorrect =>
      _selectedAnswer == _currentChord?.chordType.nameCn;

  void nextChord() {
    if (_debounceTimer?.isActive == true) return;
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {});

    _currentChord = _generator.generate();
    _selectedAnswer = null;
    _state = ChordPlayState.idle;
    notifyListeners();
  }

  Future<void> playChord() async {
    if (_currentChord == null || isPlaying) return;
    _state = ChordPlayState.playing;
    notifyListeners();

    const durationMs = 1800;
    _scheduler.playChord(_currentChord!.midiNotes, durationMs: durationMs);

    await Future.delayed(const Duration(milliseconds: durationMs));
    _state = ChordPlayState.idle;
    notifyListeners();
  }

  void submitAnswer(String answer) {
    if (hasAnswered || _currentChord == null) return;
    _selectedAnswer = answer;
    _state = ChordPlayState.answered;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
