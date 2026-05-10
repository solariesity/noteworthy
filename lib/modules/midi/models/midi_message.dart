import 'dart:typed_data';

class MidiMessage {
  final int status;
  final int data1;
  final int data2;

  const MidiMessage({
    required this.status,
    required this.data1,
    required this.data2,
  });

  factory MidiMessage.noteOn({
    required int channel,
    required int note,
    int velocity = 100,
  }) {
    return MidiMessage(
      status: 0x90 | (channel & 0x0F),
      data1: note & 0x7F,
      data2: velocity & 0x7F,
    );
  }

  factory MidiMessage.noteOff({
    required int channel,
    required int note,
  }) {
    return MidiMessage(
      status: 0x80 | (channel & 0x0F),
      data1: note & 0x7F,
      data2: 0,
    );
  }

  factory MidiMessage.programChange({
    required int channel,
    required int program,
  }) {
    return MidiMessage(
      status: 0xC0 | (channel & 0x0F),
      data1: program & 0x7F,
      data2: 0,
    );
  }

  int toWin32Dword() {
    return status | (data1 << 8) | (data2 << 16);
  }

  Uint8List toBytes() {
    return Uint8List.fromList([status, data1, data2]);
  }
}
