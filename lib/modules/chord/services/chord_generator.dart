import 'dart:math';
import '../models/chord_definition.dart';
import '../models/chord_instance.dart';

class ChordGenerator {
  static const _rootRangeStart = 48;
  static const _rootRangeEnd = 72;

  static const List<String> _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  final Random _random = Random();

  ChordInstance generate() {
    final rootNote = _rootRangeStart +
        _random.nextInt(_rootRangeEnd - _rootRangeStart + 1);
    final chordType =
        ChordDefinition.all[_random.nextInt(ChordDefinition.all.length)];
    final midiNotes =
        chordType.intervals.map((i) => rootNote + i).toList();

    return ChordInstance(
      rootNote: rootNote,
      rootName: _noteNames[rootNote % 12],
      chordType: chordType,
      midiNotes: midiNotes,
    );
  }
}
