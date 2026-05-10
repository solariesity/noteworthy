import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/piano_keyboard.dart';
import '../../../core/widgets/back_header.dart';
import '../../midi/services/midi_player.dart';

class FreePlayView extends StatefulWidget {
  final VoidCallback onBack;

  const FreePlayView({super.key, required this.onBack});

  @override
  State<FreePlayView> createState() => _FreePlayViewState();
}

class _FreePlayViewState extends State<FreePlayView> {
  final _markedNotes = <int>{};
  bool _marking = false;

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
              widget.onBack();
            },
            title: '弹奏模式',
            trailing: [
              _buildButton(
                icon: Icons.edit_location,
                label: '标记',
                active: _marking,
                color: _marking ? theme.colorScheme.primary : null,
                onTap: () => setState(() => _marking = !_marking),
              ),
              const SizedBox(width: 4),
              _buildButton(
                icon: Icons.play_arrow,
                label: '播放',
                onTap: () {
                  for (final note in _markedNotes) {
                    midiPlayer.noteOn(channel: 0, note: note);
                  }
                },
              ),
              const SizedBox(width: 4),
              _buildButton(
                icon: Icons.clear,
                label: '清除',
                onTap: () {
                  midiPlayer.allNotesOff();
                  setState(() {
                    _markedNotes.clear();
                    _marking = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PianoKeyboard(
                highlightedNotes: _markedNotes,
                onKeyDown: (note) {
                  midiPlayer.noteOn(channel: 0, note: note);
                  if (_marking) {
                    setState(() {
                      if (_markedNotes.contains(note)) {
                        _markedNotes.remove(note);
                      } else {
                        _markedNotes.add(note);
                      }
                    });
                  }
                },
                onKeyUp: (note) => midiPlayer.noteOff(channel: 0, note: note),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _marking ? '标记模式：点击琴键标记音符' : '点击琴键自由弹奏',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
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
