import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chord_instance.dart';
import '../services/chord_generator.dart';
import '../../../midi/services/midi_scheduler.dart';

enum ProgressionPlayState { idle, playing, played, revealed }

class ProgressionRevealProvider extends ChangeNotifier {
  final ChordGenerator _generator;
  final MidiScheduler _scheduler;
  final Random _random = Random();

  int? _rootNote;
  List<ChordInstance> _chords = [];
  ProgressionPlayState _state = ProgressionPlayState.idle;
  int _currentChordIndex = -1;
  bool _hasPlayed = false;

  ProgressionRevealProvider(this._generator, this._scheduler);

  int? get rootNote => _rootNote;
  List<ChordInstance> get chords => _chords;
  ProgressionPlayState get state => _state;
  int get currentChordIndex => _currentChordIndex;
  bool get hasPlayed => _hasPlayed;
  bool get isPlaying => _state == ProgressionPlayState.playing;
  bool get hasRevealed => _state == ProgressionPlayState.revealed;
  bool get canReveal => _state == ProgressionPlayState.played;

  void nextProgression() {
    _rootNote = 48 + _random.nextInt(25); // 48-72
    final count = 3 + _random.nextInt(2); // 3-4 chords
    _chords = List.generate(
      count,
      (_) => _generator.generateWithRoot(_rootNote!),
    );
    _state = ProgressionPlayState.idle;
    _currentChordIndex = -1;
    _hasPlayed = false;
    notifyListeners();
  }

  Future<void> playProgression() async {
    if (_chords.isEmpty || isPlaying) return;

    _state = ProgressionPlayState.playing;
    _hasPlayed = true;
    _currentChordIndex = -1;
    notifyListeners();

    _scheduler.playChord([_rootNote!], durationMs: 1200);
    await Future.delayed(const Duration(milliseconds: 1500));

    for (var i = 0; i < _chords.length; i++) {
      if (_state != ProgressionPlayState.playing) return;
      _currentChordIndex = i;
      notifyListeners();
      _scheduler.playChord(_chords[i].midiNotes, durationMs: 1800);
      await Future.delayed(const Duration(milliseconds: 2200));
    }

    if (_state == ProgressionPlayState.playing) {
      _currentChordIndex = -1;
      _state = ProgressionPlayState.played;
      notifyListeners();
    }
  }

  void reveal() {
    if (_state != ProgressionPlayState.played) return;
    _state = ProgressionPlayState.revealed;
    notifyListeners();
  }
}
