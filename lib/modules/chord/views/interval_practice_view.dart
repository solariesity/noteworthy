import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/noteful_card.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/piano_keyboard.dart';
import '../../../midi/services/midi_player.dart';
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                    ),
                    const SizedBox(width: 8),
                    Text('音程练习', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
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

    final highlightedNotes = <int>{noteA};
    if (provider.hasAnswered && provider.noteB != null) {
      highlightedNotes.add(provider.noteB!);
    }

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
        _PlayButton(
          onPressed: provider.isPlaying ? null : () => provider.playSequence(),
          isPlaying: provider.isPlaying,
        ),
        if (provider.hasPlayed) ...[
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: () {
              final rangeStart = (noteA - 12).clamp(36, 60);
              final rangeEnd = (noteA + 12).clamp(rangeStart + 24, 84);
              return PianoKeyboard(
                startNote: rangeStart,
                endNote: rangeEnd,
                highlightedNotes: highlightedNotes,
                onKeyDown: provider.isPlaying || provider.hasAnswered
                    ? null
                    : (note) {
                        midiPlayer.noteOn(channel: 0, note: note);
                        provider.submitAnswer(
                          IntervalPracticeProvider.noteDisplay(note),
                        );
                      },
                onKeyUp: (note) {
                  midiPlayer.noteOff(channel: 0, note: note);
                },
              );
            }(),
          ),
          if (provider.hasAnswered) ...[
            const SizedBox(height: 20),
            _FeedbackArea(
              isCorrect: provider.isCorrect,
              answerDisplay: provider.answerDisplay,
            ),
          ],
        ],
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isPlaying;

  const _PlayButton({required this.onPressed, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPlaying
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: (isPlaying
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer)
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.graphic_eq : Icons.play_arrow,
          size: 40,
          color: isPlaying
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _FeedbackArea extends StatelessWidget {
  final bool isCorrect;
  final String answerDisplay;

  const _FeedbackArea({
    required this.isCorrect,
    required this.answerDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          size: 36,
          color: isCorrect ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        Text(
          isCorrect ? '正确！' : '不对哦',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '答案是：$answerDisplay',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
