import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/feedback_area.dart';
import '../../../core/widgets/noteful_card.dart';
import '../../../core/widgets/piano_keyboard.dart';
import '../../../core/widgets/play_button.dart';
import '../../midi/services/midi_player.dart';
import '../providers/interval_practice_provider.dart';

class IntervalPracticeView extends StatelessWidget {
  final VoidCallback onBack;

  const IntervalPracticeView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<IntervalPracticeProvider>(
      builder: (context, provider, _) {
        final noteA = provider.noteA;

        if (noteA == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Column(
            children: [
              BackHeader(onBack: onBack, title: '音程练习'),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: NotefulCard(
                      child: _IntervalContent(provider: provider, noteA: noteA),
                    ),
                  ),
                ),
              ),
              if (provider.hasAnswered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ActionButton(
                    label: '下一个',
                    icon: Icons.arrow_forward,
                    onPressed: () => provider.nextQuestion(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _IntervalContent extends StatelessWidget {
  final IntervalPracticeProvider provider;
  final int noteA;

  const _IntervalContent({required this.provider, required this.noteA});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final midiPlayer = context.read<MidiPlayer>();

    final highlightedNotes = <int>{
      noteA,
      if (provider.hasAnswered && provider.noteB != null) provider.noteB!,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('这是什么音？', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(
          '先听参考音，再在钢琴上点击你听到的第二个音',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        PlayButton(
          onPressed: provider.isPlaying ? null : () => provider.playSequence(),
          isPlaying: provider.isPlaying,
        ),
        if (provider.hasPlayed) ...[
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _buildKeyboard(midiPlayer, highlightedNotes),
          ),
          if (provider.hasAnswered) ...[
            const SizedBox(height: 20),
            FeedbackArea(
              isCorrect: provider.isCorrect,
              extra: [
                const SizedBox(height: 4),
                Text('答案是：${provider.answerDisplay}',
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildKeyboard(MidiPlayer midiPlayer, Set<int> highlightedNotes) {
    final (rangeStart, rangeEnd) = PianoKeyboard.rangeAround(noteA);
    final lockTaps = provider.isPlaying || provider.hasAnswered;
    return PianoKeyboard(
      startNote: rangeStart,
      endNote: rangeEnd,
      highlightedNotes: highlightedNotes,
      onKeyDown: lockTaps
          ? null
          : (note) {
              midiPlayer.noteOn(channel: 0, note: note);
              provider.submitAnswer(IntervalPracticeProvider.noteDisplay(note));
            },
      onKeyUp: (note) => midiPlayer.noteOff(channel: 0, note: note),
    );
  }
}
