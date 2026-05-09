import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/noteful_card.dart';
import '../../../core/widgets/action_button.dart';
import '../providers/word_provider.dart';
import '../providers/plan_provider.dart';
import '../models/word_entry.dart';

class WordCardView extends StatelessWidget {
  final VoidCallback? onBack;

  const WordCardView({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<WordProvider>(
      builder: (context, provider, _) {
        final word = provider.currentWord;
        if (word == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Column(
            children: [
              if (onBack != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onBack,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: NotefulCard(child: _WordContent(word: word)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ActionButton(
                        label: '下一个词',
                        icon: Icons.arrow_forward,
                        onPressed: () => provider.nextWord(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Consumer<PlanProvider>(
                      builder: (context, planProvider, _) {
                        final favorited = planProvider.isFavorited(word.word);
                        return IconButton.filled(
                          onPressed: () => planProvider.toggleFavorite(word),
                          icon: Icon(favorited ? Icons.star : Icons.star_border),
                          style: IconButton.styleFrom(
                            backgroundColor: favorited
                                ? Colors.amber.shade700
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            foregroundColor: favorited
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WordContent extends StatelessWidget {
  final WordEntry word;

  const _WordContent({required this.word});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(word.word, style: theme.textTheme.headlineLarge),
            ),
            const SizedBox(width: 10),
            Text(
              word.partOfSpeech,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          word.pronunciation,
          style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 14),
        Text(word.definitionCn, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text(
          word.definitionEn,
          style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        if (word.examples.isNotEmpty) ...[
          const SizedBox(height: 24),
          _DividerLine(),
          const SizedBox(height: 18),
          _ExamplesContent(examples: word.examples),
        ],
        if (word.rootAnalysis != null) ...[
          const SizedBox(height: 20),
          _DividerLine(),
          const SizedBox(height: 18),
          _RootContent(root: word.rootAnalysis!),
        ],
        if (word.collocations.isNotEmpty) ...[
          const SizedBox(height: 20),
          _DividerLine(),
          const SizedBox(height: 18),
          _CollocationsContent(collocations: word.collocations),
        ],
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
      height: 1,
    );
  }
}

class _ExamplesContent extends StatelessWidget {
  final List<ExampleSentence> examples;

  const _ExamplesContent({required this.examples});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: examples.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 8),
              child: Icon(Icons.auto_awesome,
                  size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.en, style: theme.textTheme.bodyMedium),
                  Text(
                    e.cn,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _RootContent extends StatelessWidget {
  final RootAnalysis root;

  const _RootContent({required this.root});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: root.components.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${c.part}  ${c.meaning}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          )).toList(),
        ),
        if (root.overallMeaning != null) ...[
          const SizedBox(height: 6),
          Text(root.overallMeaning!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _CollocationsContent extends StatelessWidget {
  final List<Collocation> collocations;

  const _CollocationsContent({required this.collocations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: collocations.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Icon(Icons.auto_awesome,
                  size: 12, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            Text(
              c.phrase,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                c.meaning,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
