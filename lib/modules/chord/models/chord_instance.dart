import '../../../core/constants.dart';
import 'chord_definition.dart';

class ChordInstance {
  final int rootNote;
  final String rootName;
  final ChordDefinition chordType;
  final List<int> midiNotes;

  const ChordInstance({
    required this.rootNote,
    required this.rootName,
    required this.chordType,
    required this.midiNotes,
  });

  String get answerLabel => '$rootName${chordType.nameCn}';

  String get noteNames => midiNotes
      .map((n) => '${kNoteNames[n % 12]}${(n ~/ 12) - 1}')
      .join(' ');
}
