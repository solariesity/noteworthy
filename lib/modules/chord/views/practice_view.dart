import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/feedback_area.dart';
import '../../../core/widgets/noteful_card.dart';
import '../../../core/widgets/piano_keyboard.dart';
import '../../../core/widgets/play_button.dart';
import '../models/chord_definition.dart';
import '../models/chord_instance.dart';
import '../providers/chord_provider.dart';

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
              BackHeader(onBack: onBack, title: '练习模式'),
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
  final ChordInstance chord;

  const _ChordContent({required this.provider, required this.chord});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('这是什么和弦？', style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        PlayButton(
          onPressed: provider.isPlaying ? null : () => provider.playChord(),
          isPlaying: provider.isPlaying,
        ),
        const SizedBox(height: 24),
        _ChoiceChips(provider: provider, chord: chord),
        if (provider.hasAnswered) ...[
          const SizedBox(height: 20),
          FeedbackArea(
            isCorrect: provider.isCorrect,
            extra: [
              const SizedBox(height: 4),
              Text(chord.answerLabel, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                '构成音：${chord.noteNames}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '色彩：${chord.chordType.color}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: _buildAnswerKeyboard(),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerKeyboard() {
    final notes = chord.midiNotes;
    final lo = notes.reduce((a, b) => a < b ? a : b);
    final hi = notes.reduce((a, b) => a > b ? a : b);
    final (rangeStart, rangeEnd) = PianoKeyboard.rangeForRange(lo, hi);
    return PianoKeyboard(
      startNote: rangeStart,
      endNote: rangeEnd,
      highlightedNotes: notes.toSet(),
    );
  }
}

class _ChoiceChips extends StatelessWidget {
  final ChordProvider provider;
  final ChordInstance chord;

  const _ChoiceChips({required this.provider, required this.chord});

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
          onSelected: provider.hasAnswered ? null : (_) => _onSelect(context, cd),
          backgroundColor: backgroundColor,
          labelStyle: textColor != null ? TextStyle(color: textColor) : null,
        );
      }).toList(),
    );
  }

  void _onSelect(BuildContext context, ChordDefinition cd) {
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
  }
}
