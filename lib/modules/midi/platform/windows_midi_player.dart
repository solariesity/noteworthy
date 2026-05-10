import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../models/midi_message.dart';
import '../services/midi_player.dart';

// winmm.dll 的 FFI 绑定：通过 midiOutShortMsg 发送 MIDI 消息
final _winmm = DynamicLibrary.open('winmm.dll');

typedef _MidiOutGetNumDevsC = Uint32 Function();
typedef _MidiOutGetNumDevsDart = int Function();

typedef _MidiOutOpenC = Int32 Function(
  Pointer<IntPtr>, Int32, IntPtr, IntPtr, Int32,
);
typedef _MidiOutOpenDart = int Function(
  Pointer<IntPtr>, int, int, int, int,
);

typedef _MidiOutShortMsgC = Int32 Function(IntPtr, Uint32);
typedef _MidiOutShortMsgDart = int Function(int, int);

typedef _MidiOutCloseC = Int32 Function(IntPtr);
typedef _MidiOutCloseDart = int Function(int);

final _midiOutGetNumDevs = _winmm
    .lookupFunction<_MidiOutGetNumDevsC, _MidiOutGetNumDevsDart>(
        'midiOutGetNumDevs');

final _midiOutOpen =
    _winmm.lookupFunction<_MidiOutOpenC, _MidiOutOpenDart>('midiOutOpen');

final _midiOutShortMsg = _winmm
    .lookupFunction<_MidiOutShortMsgC, _MidiOutShortMsgDart>(
        'midiOutShortMsg');

final _midiOutClose =
    _winmm.lookupFunction<_MidiOutCloseC, _MidiOutCloseDart>('midiOutClose');

const _mmsyserrNoerror = 0;

class WindowsMidiPlayer extends MidiPlayer {
  int _deviceHandle = 0;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    final numDevs = _midiOutGetNumDevs();
    if (numDevs == 0) {
      _initialized = false;
      return;
    }

    final hMidiOut = calloc.allocate<IntPtr>(sizeOf<IntPtr>());
    final result = _midiOutOpen(hMidiOut, -1, 0, 0, 0);
    if (result != _mmsyserrNoerror) {
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
  void noteOn(
      {required int channel, required int note, int velocity = 100}) {
    if (!_initialized) return;
    final msg =
        MidiMessage.noteOn(channel: channel, note: note, velocity: velocity);
    _midiOutShortMsg(_deviceHandle, msg.toWin32Dword());
  }

  @override
  void noteOff({required int channel, required int note}) {
    if (!_initialized) return;
    final msg = MidiMessage.noteOff(channel: channel, note: note);
    _midiOutShortMsg(_deviceHandle, msg.toWin32Dword());
  }

  @override
  void programChange({required int channel, required int program}) {
    if (!_initialized) return;
    final msg =
        MidiMessage.programChange(channel: channel, program: program);
    _midiOutShortMsg(_deviceHandle, msg.toWin32Dword());
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
    _midiOutClose(_deviceHandle);
    _initialized = false;
  }
}
