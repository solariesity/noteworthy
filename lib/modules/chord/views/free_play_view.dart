import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/piano_keyboard.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/constants.dart';
import '../../midi/services/midi_player.dart';
import '../../midi/services/midi_scheduler.dart';
import '../models/chord_definition.dart';

class FreePlayView extends StatefulWidget {
  final VoidCallback onBack;

  const FreePlayView({super.key, required this.onBack});

  @override
  State<FreePlayView> createState() => _FreePlayViewState();
}

class _FreePlayViewState extends State<FreePlayView> {
  final _markedNotes = <int>{};
  bool _marking = false;
  bool _chordMode = false;
  int? _selectedRoot;
  late final MidiScheduler _scheduler;

  @override
  void initState() {
    super.initState();
    _scheduler = MidiScheduler(context.read<MidiPlayer>());
  }

  @override
  void dispose() {
    _scheduler.stop();
    super.dispose();
  }

  ChordDefinition? _chordType;

  /// 已有的和弦音符（当前 _selectedRoot + _chordType）
  Set<int> get _chordNotes => _chordNotesFor(_selectedRoot, _chordType);

  /// 计算给定根音 + 和弦类型的音符集合
  Set<int> _chordNotesFor(int? root, ChordDefinition? type) {
    if (root == null || type == null) return {};
    return type.intervals.map((i) => root + i).toSet();
  }

  void _onKeyDown(int note, MidiPlayer midiPlayer) {
    midiPlayer.noteOn(channel: 0, note: note);

    if (_chordMode) {
      setState(() => _selectedRoot = note);
      return;
    }

    if (_marking) {
      setState(() {
        if (_markedNotes.contains(note)) {
          _markedNotes.remove(note);
        } else {
          _markedNotes.add(note);
        }
      });
    }
  }

  void _onChordTypeSelected(ChordDefinition def) {
    if (_selectedRoot == null) return;

    setState(() {
      // 先移除上一次加入的和弦音符
      final prevNotes = _chordNotesFor(_selectedRoot!, _chordType);
      _markedNotes.removeAll(prevNotes);
      _chordType = def;
      _markedNotes.addAll(_chordNotes);
    });

    _scheduler.playChord(_chordNotes.toList());
  }

  void _playMarked(MidiPlayer midiPlayer) {
    for (final note in _markedNotes) {
      midiPlayer.noteOn(channel: 0, note: note);
    }
  }

  void _clearAll(MidiPlayer midiPlayer) {
    midiPlayer.allNotesOff();
    _scheduler.stop();
    setState(() {
      _markedNotes.clear();
      _marking = false;
      _selectedRoot = null;
      _chordType = null;
    });
  }

  void _toggleChordMode() {
    setState(() {
      _chordMode = !_chordMode;
      if (_chordMode) _marking = false;
      _selectedRoot = null;
      _chordType = null;
    });
  }

  void _toggleMarking() {
    setState(() {
      _marking = !_marking;
      if (_marking) _chordMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final midiPlayer = context.read<MidiPlayer>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          BackHeader(
            onBack: () {
              midiPlayer.allNotesOff();
              _scheduler.stop();
              widget.onBack();
            },
            title: '弹奏模式',
            trailing: [
              _buildButton(
                icon: Icons.music_note,
                label: '和弦',
                active: _chordMode,
                color: _chordMode ? theme.colorScheme.primary : null,
                onTap: _toggleChordMode,
              ),
              const SizedBox(width: 4),
              _buildButton(
                icon: Icons.edit_location,
                label: '标记',
                active: _marking,
                color: _marking ? theme.colorScheme.primary : null,
                onTap: _toggleMarking,
              ),
              const SizedBox(width: 4),
              _buildButton(
                icon: Icons.play_arrow,
                label: '播放',
                onTap: () => _playMarked(midiPlayer),
              ),
              const SizedBox(width: 4),
              _buildButton(
                icon: Icons.clear,
                label: '清除',
                onTap: () => _clearAll(midiPlayer),
              ),
            ],
          ),
          if (_chordMode) _buildChordChips(theme),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PianoKeyboard(
              height: 240,
              highlightedNotes: _chordMode ? _chordNotes : _markedNotes,
              rootNote: _chordMode ? _selectedRoot : null,
              onKeyDown: (note) => _onKeyDown(note, midiPlayer),
              onKeyUp: (note) => midiPlayer.noteOff(channel: 0, note: note),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _buildStatusText(),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _buildStatusText() {
    if (_chordMode) {
      if (_selectedRoot == null) return '和弦模式：点击琴键选择根音';
      final rootName = kNoteNames[_selectedRoot! % 12];
      if (_chordType == null) return '根音：$rootName — 请选择和弦类型';
      return '$rootName${_chordType!.nameCn}  ${_chordType!.color}';
    }
    if (_marking) return '标记模式：点击琴键标记音符';
    return '点击琴键自由弹奏';
  }

  Widget _buildChordChips(ThemeData theme) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ChordDefinition.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final def = ChordDefinition.all[index];
          final selected = _chordType?.id == def.id;
          return ChoiceChip(
            label: Text(def.nameCn),
            selected: selected,
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.25),
            onSelected: (_) => _onChordTypeSelected(def),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    bool active = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        visualDensity: VisualDensity.compact,
        backgroundColor: active ? color?.withValues(alpha: 0.12) : null,
      ),
    );
  }
}
