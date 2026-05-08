import 'package:flutter/services.dart';
import '../services/midi_player.dart';

class AndroidMidiPlayer extends MidiPlayer {
  static const _channel = MethodChannel('noteworthy/midi');
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  @override
  void noteOn({required int channel, required int note, int velocity = 100}) {
    if (!_initialized) return;
    _channel.invokeMethod('noteOn', {
      'note': note,
      'velocity': velocity,
      'channel': channel,
    });
  }

  @override
  void noteOff({required int channel, required int note}) {
    if (!_initialized) return;
    _channel.invokeMethod('noteOff', {
      'note': note,
      'channel': channel,
    });
  }

  @override
  void programChange({required int channel, required int program}) {
    if (!_initialized) return;
    _channel.invokeMethod('programChange', {
      'program': program,
      'channel': channel,
    });
  }

  @override
  void allNotesOff() {
    _channel.invokeMethod('allNotesOff');
  }

  @override
  void dispose() {
    allNotesOff();
  }
}
