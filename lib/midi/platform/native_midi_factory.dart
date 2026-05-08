import 'dart:io' show Platform;
import '../services/midi_player.dart';
import 'windows_midi_player.dart';
import 'android_midi_player.dart';

MidiPlayer createNativeMidiPlayer() {
  if (Platform.isWindows) return WindowsMidiPlayer();
  if (Platform.isAndroid) return AndroidMidiPlayer();
  throw UnsupportedError('Unsupported platform for native MIDI');
}
