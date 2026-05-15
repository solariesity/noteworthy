import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/noteful_card.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/piano_keyboard.dart';
import '../../../core/widgets/play_button.dart';
import '../providers/progression_reveal_provider.dart';

class ProgressionRevealView extends StatelessWidget {
  final VoidCallback onBack;

  const ProgressionRevealView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressionRevealProvider>(
      builder: (context, provider, _) {
        final rootNote = provider.rootNote;

        if (rootNote == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Column(
            children: [
              BackHeader(onBack: onBack, title: '和弦进行'),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: NotefulCard(
                      child: _ProgressionContent(
                        provider: provider,
                        rootNote: rootNote,
                      ),
                    ),
                  ),
                ),
              ),
              if (provider.hasRevealed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ActionButton(
                    label: '下一个',
                    icon: Icons.arrow_forward,
                    onPressed: () => provider.nextProgression(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressionContent extends StatelessWidget {
  final ProgressionRevealProvider provider;
  final int rootNote;

  const _ProgressionContent({
    required this.provider,
    required this.rootNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('听辨和弦进行', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(
          '聆听一组和弦，猜猜它们是什么',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        PlayButton(
          onPressed: provider.isPlaying
              ? null
              : () => provider.playProgression(),
          isPlaying: provider.isPlaying,
        ),
        if (provider.isPlaying) ...[
          const SizedBox(height: 16),
          Text(
            provider.currentChordIndex < 0
                ? '播放根音...'
                : '第 ${provider.currentChordIndex + 1} 个和弦',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        if (provider.hasPlayed) ...[
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: Builder(builder: (context) {
              final rangeStart = (rootNote - 12).clamp(36, 60);
              final rangeEnd = (rootNote + 12).clamp(rangeStart + 24, 84);
              return PianoKeyboard(
                startNote: rangeStart,
                endNote: rangeEnd,
                highlightedNotes: {rootNote},
              );
            }),
          ),
          const SizedBox(height: 20),
          if (provider.canReveal)
            ActionButton(
              label: '显示答案',
              icon: Icons.visibility,
              onPressed: () => provider.reveal(),
            ),
          if (provider.hasRevealed) ...[
            const SizedBox(height: 8),
            ...provider.chords.asMap().entries.map((e) {
              final i = e.key;
              final chord = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                chord.answerLabel,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                chord.chordType.nameEn,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '色彩：${chord.chordType.color}   组成：${chord.noteNames}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ],
    );
  }
}

