import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/piano_keyboard.dart';
import '../../../midi/services/midi_player.dart';

class FreePlayView extends StatelessWidget {
  final VoidCallback onBack;

  const FreePlayView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final midiPlayer = context.read<MidiPlayer>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    midiPlayer.allNotesOff();
                    onBack();
                  },
                ),
                const SizedBox(width: 8),
                Text('弹奏模式', style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PianoKeyboard(
                onKeyDown: (note) =>
                    midiPlayer.noteOn(channel: 0, note: note),
                onKeyUp: (note) =>
                    midiPlayer.noteOff(channel: 0, note: note),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '点击琴键自由弹奏',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
