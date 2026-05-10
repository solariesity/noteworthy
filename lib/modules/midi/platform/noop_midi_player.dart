import '../services/midi_player.dart';

class NoopMidiPlayer extends MidiPlayer {
  @override
  Future<void> initialize() async {}

  @override
  void noteOn({required int channel, required int note, int velocity = 100}) {}

  @override
  void noteOff({required int channel, required int note}) {}

  @override
  void programChange({required int channel, required int program}) {}

  @override
  void allNotesOff() {}

  @override
  void dispose() {}
}

MidiPlayer createNativeMidiPlayer() => NoopMidiPlayer();
