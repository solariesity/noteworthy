abstract class MidiPlayer {
  Future<void> initialize();
  void noteOn({required int channel, required int note, int velocity = 100});
  void noteOff({required int channel, required int note});
  void programChange({required int channel, required int program});
  void allNotesOff();
  void dispose();
}
