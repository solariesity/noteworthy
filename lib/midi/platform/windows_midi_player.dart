import 'dart:ffi';
import 'package:ffi/ffi.dart' show calloc;
import 'package:win32/win32.dart';
import '../models/midi_message.dart';
import '../services/midi_player.dart';

class WindowsMidiPlayer extends MidiPlayer {
  int _deviceHandle = 0;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    final numDevs = midiOutGetNumDevs();
    if (numDevs == 0) {
      _initialized = false;
      return;
    }

    final hMidiOut = calloc.allocate<IntPtr>(sizeOf<IntPtr>());
    final result = midiOutOpen(hMidiOut, -1, 0, 0, 0);
    if (result != MMSYSERR_NOERROR) {
      calloc.free(hMidiOut);
      return;
    }

    _deviceHandle = hMidiOut.value;
    calloc.free(hMidiOut);
    _initialized = true;

    programChange(channel: 0, program: 0);
  }

  bool get isAvailable => _initialized;

  @override
  void noteOn({required int channel, required int note, int velocity = 100}) {
    if (!_initialized) return;
    final msg = MidiMessage.noteOn(channel: channel, note: note, velocity: velocity);
    midiOutShortMsg(_deviceHandle, msg.toWin32Dword());
  }

  @override
  void noteOff({required int channel, required int note}) {
    if (!_initialized) return;
    final msg = MidiMessage.noteOff(channel: channel, note: note);
    midiOutShortMsg(_deviceHandle, msg.toWin32Dword());
  }

  @override
  void programChange({required int channel, required int program}) {
    if (!_initialized) return;
    final msg = MidiMessage.programChange(channel: channel, program: program);
    midiOutShortMsg(_deviceHandle, msg.toWin32Dword());
  }

  @override
  void allNotesOff() {
    if (!_initialized) return;
    for (int note = 0; note < 128; note++) {
      noteOff(channel: 0, note: note);
    }
  }

  @override
  void dispose() {
    if (!_initialized) return;
    allNotesOff();
    midiOutClose(_deviceHandle);
    _initialized = false;
  }
}
