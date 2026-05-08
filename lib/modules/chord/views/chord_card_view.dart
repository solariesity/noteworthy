import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/noteful_card.dart';
import '../../../core/widgets/action_button.dart';
import '../providers/chord_provider.dart';
import '../models/chord_definition.dart';

class ChordCardView extends StatelessWidget {
  const ChordCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChordProvider>(
      builder: (context, provider, _) {
        final chord = provider.currentChord;

        if (chord == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                NotefulCard(
                  child: _ChordContent(provider: provider, chord: chord),
                ),
                const SizedBox(height: 16),
                if (provider.hasAnswered)
                  ActionButton(
                    label: '下一个和弦',
                    icon: Icons.arrow_forward,
                    onPressed: () => provider.nextChord(),
                  ),
                const SizedBox(height: 24),
              ],
            ),
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
        Text('这是什么和弦？',
            style: theme.textTheme.titleLarge),
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
            final isCorrectAnswer = provider.hasAnswered &&
                chord.chordType.id == cd.id;
            final isWrong = provider.hasAnswered &&
                isSelected &&
                !provider.isCorrect;

            Color? backgroundColor;
            Color? textColor;

            if (isCorrectAnswer) {
              backgroundColor = Colors.green.shade100;
              textColor = Colors.green.shade800;
            } else if (isWrong) {
              backgroundColor = Colors.red.shade100;
              textColor = Colors.red.shade800;
            }

            return ChoiceChip(
              label: Text(cd.nameCn),
              selected: isSelected,
              onSelected: provider.hasAnswered
                  ? null
                  : (_) => provider.submitAnswer(cd.nameCn),
              backgroundColor: backgroundColor,
              labelStyle: textColor != null
                  ? TextStyle(color: textColor)
                  : null,
            );
          }).toList(),
        ),
        if (provider.hasAnswered) ...[
          const SizedBox(height: 20),
          _FeedbackArea(
            isCorrect: provider.isCorrect,
            answerLabel: chord.answerLabel,
            chordColor: chord.chordType.color,
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

  const _FeedbackArea({
    required this.isCorrect,
    required this.answerLabel,
    required this.chordColor,
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
          answerLabel,
          style: theme.textTheme.bodyMedium,
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
