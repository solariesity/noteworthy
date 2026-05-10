import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/back_header.dart';
import '../providers/word_provider.dart';
import '../providers/favorites_provider.dart';
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
              if (onBack != null) BackHeader(onBack: onBack),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: _WordContent(word: word),
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
                    Consumer<FavoritesProvider>(
                      builder: (context, favProvider, _) {
                        final favorited = favProvider.isFavorited(word.word);
                        return IconButton.filled(
                          onPressed: () => favProvider.toggleFavorite(word.word),
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
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          word.pronunciation,
          style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 22),
        Text(word.definitionCn, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          word.definitionEn,
          style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
        if (word.examples.isNotEmpty) ...[
          const SizedBox(height: 36),
          const _SectionDivider(),
          const SizedBox(height: 28),
          _ExamplesContent(examples: word.examples),
        ],
        if (word.rootAnalysis != null) ...[
          const SizedBox(height: 32),
          const _SectionDivider(),
          const SizedBox(height: 28),
          _RootContent(root: word.rootAnalysis!),
        ],
        if (word.collocations.isNotEmpty) ...[
          const SizedBox(height: 32),
          const _SectionDivider(),
          const SizedBox(height: 28),
          _CollocationsContent(collocations: word.collocations),
        ],
      ],
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
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 10),
              child: Icon(Icons.auto_awesome,
                  size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.en, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    e.cn,
                    style: theme.textTheme.bodyMedium?.copyWith(
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${c.part}  ${c.meaning}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          )).toList(),
        ),
        if (root.overallMeaning != null) ...[
          const SizedBox(height: 8),
          Text(root.overallMeaning!, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
      height: 1,
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
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 10),
              child: Icon(Icons.auto_awesome,
                  size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            Text(
              c.phrase,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                c.meaning,
                style: theme.textTheme.bodyMedium?.copyWith(
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
