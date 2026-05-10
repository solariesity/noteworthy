import 'dart:async';
import 'midi_player.dart';

// 定时播放 MIDI 音符序列：noteOn 后经过 durationMs 自动 noteOff
class MidiScheduler {
  final MidiPlayer _player;
  Timer? _offTimer;
  List<int>? _activeNotes;

  MidiScheduler(this._player);

  void playChord(List<int> notes, {int channel = 0, int durationMs = 1800}) {
    stop();
    _activeNotes = List.of(notes);

    for (final note in notes) {
      _player.noteOn(channel: channel, note: note);
    }

    _offTimer = Timer(Duration(milliseconds: durationMs), () {
      for (final note in notes) {
        _player.noteOff(channel: channel, note: note);
      }
      _activeNotes = null;
    });
  }

  void stop() {
    _offTimer?.cancel();
    _offTimer = null;

    if (_activeNotes != null) {
      for (final note in _activeNotes!) {
        _player.noteOff(channel: 0, note: note);
      }
      _activeNotes = null;
    }
  }

  void dispose() {
    stop();
    _player.dispose();
  }
}
