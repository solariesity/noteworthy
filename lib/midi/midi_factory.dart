import 'services/midi_player.dart';
import 'platform/noop_midi_player.dart'
    if (dart.library.ffi) 'platform/native_midi_factory.dart';

MidiPlayer createMidiPlayer() {
  return createNativeMidiPlayer();
}
