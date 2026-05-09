import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/noteful_card.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/piano_keyboard.dart';
import '../providers/chord_provider.dart';
import '../models/chord_definition.dart';

class PracticeView extends StatelessWidget {
  final VoidCallback onBack;

  const PracticeView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChordProvider>(
      builder: (context, provider, _) {
        final chord = provider.currentChord;

        if (chord == null) {
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
                    Text('练习模式', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: NotefulCard(
                      child: _ChordContent(provider: provider, chord: chord),
                    ),
                  ),
                ),
              ),
              if (provider.hasAnswered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ActionButton(
                    label: '下一个和弦',
                    icon: Icons.arrow_forward,
                    onPressed: () => provider.nextChord(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ChordContent extends StatelessWidget {
  final ChordProvider provider;
  final dynamic chord;

  const _ChordContent({required this.provider, required this.chord});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('这是什么和弦？', style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        _PlayButton(
          onPressed: provider.isPlaying ? null : () => provider.playChord(),
          isPlaying: provider.isPlaying,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ChordDefinition.all.map((cd) {
            final isSelected = provider.selectedAnswer == cd.nameCn;
            final isCorrectAnswer =
                provider.hasAnswered && chord.chordType.id == cd.id;
            final isWrong =
                provider.hasAnswered && isSelected && !provider.isCorrect;

            Color? backgroundColor;
            Color? textColor;

            if (isCorrectAnswer) {
              backgroundColor = Colors.green.shade900;
              textColor = Colors.green.shade100;
            } else if (isWrong) {
              backgroundColor = Colors.red.shade900;
              textColor = Colors.red.shade100;
            }

            return ChoiceChip(
              label: Text(cd.nameCn),
              selected: isSelected,
              onSelected: provider.hasAnswered
                  ? null
                  : (_) {
                      if (!provider.hasPlayed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('请点击播放按钮，然后选择'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      provider.submitAnswer(cd.nameCn);
                    },
              backgroundColor: backgroundColor,
              labelStyle: textColor != null ? TextStyle(color: textColor) : null,
            );
          }).toList(),
        ),
        if (provider.hasAnswered) ...[
          const SizedBox(height: 20),
          _FeedbackArea(
            isCorrect: provider.isCorrect,
            answerLabel: chord.answerLabel,
            chordColor: chord.chordType.color,
            noteNames: chord.noteNames,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: () {
              final notes = chord.midiNotes;
              var lo = 127;
              var hi = 0;
              for (final n in notes) {
                if (n < lo) lo = n;
                if (n > hi) hi = n;
              }
              final rangeStart = (lo - 4).clamp(36, 59);
              final rangeEnd = (hi + 4).clamp(rangeStart + 25, 84);
              return PianoKeyboard(
                startNote: rangeStart,
                endNote: rangeEnd,
                highlightedNotes: notes.toSet(),
              );
            }(),
          ),
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
  final String answerLabel;
  final String chordColor;
  final String noteNames;

  const _FeedbackArea({
    required this.isCorrect,
    required this.answerLabel,
    required this.chordColor,
    required this.noteNames,
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
        Text(answerLabel, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 2),
        Text(
          '构成音：$noteNames',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '色彩：$chordColor',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
