import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../midi/services/midi_scheduler.dart';

enum IntervalPlayState { idle, playingA, playingB, answered }

class IntervalPracticeProvider extends ChangeNotifier {
  final MidiScheduler _scheduler;

  int? _noteA;
  int? _noteB;
  IntervalPlayState _state = IntervalPlayState.idle;
  String? _selectedAnswer;
  bool _hasPlayed = false;

  IntervalPracticeProvider(this._scheduler);

  // 出题时第一个音 (noteA) 的取值范围：[C3, C5]，即 25 个半音。
  static const _noteARangeStart = kMidiC3; // 48
  static const _noteARangeSpan = kMidiC5 - kMidiC3 + 1; // 25
  // 第二个音 (noteB) 相对 noteA 的最大上下偏移（一个八度）。
  static const _intervalMaxOffset = 12;

  // 播放时长：参考音 1.2s，目标音 1.5s；每个音之后留 300ms 间隔再进入下一阶段。
  static const _refDurationMs = 1200;
  static const _targetDurationMs = 1500;
  static const _gapAfterNoteMs = 300;

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
    final name = kNoteNames[note % 12];
    final octave = (note ~/ 12) - 1;
    return '$name$octave';
  }

  void nextQuestion() {
    final random = Random();
    _noteA = _noteARangeStart + random.nextInt(_noteARangeSpan);
    do {
      final offset = random.nextInt(_intervalMaxOffset * 2 + 1) - _intervalMaxOffset;
      _noteB = (_noteA! + offset).clamp(kPianoMinNote, kPianoMaxNote);
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

    _scheduler.playChord([_noteA!], durationMs: _refDurationMs);
    await Future.delayed(
      const Duration(milliseconds: _refDurationMs + _gapAfterNoteMs),
    );

    if (_state != IntervalPlayState.playingA) return;

    _state = IntervalPlayState.playingB;
    notifyListeners();

    _scheduler.playChord([_noteB!], durationMs: _targetDurationMs);
    await Future.delayed(
      const Duration(milliseconds: _targetDurationMs + _gapAfterNoteMs),
    );

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
