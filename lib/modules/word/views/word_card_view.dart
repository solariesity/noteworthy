import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/noteful_card.dart';
import '../../../core/widgets/action_button.dart';
import '../providers/word_provider.dart';
import '../models/word_entry.dart';

class WordCardView extends StatelessWidget {
  const WordCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WordProvider>(
      builder: (context, provider, _) {
        final word = provider.currentWord;
        if (word == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                NotefulCard(
                  child: _WordContent(word: word),
                ),
                const SizedBox(height: 16),
                ActionButton(
                  label: '下一个词',
                  icon: Icons.arrow_forward,
                  onPressed: () => provider.nextWord(),
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
            Text(word.word, style: theme.textTheme.headlineMedium),
            const SizedBox(width: 8),
            Text(word.partOfSpeech,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
        const SizedBox(height: 4),
        Text(word.pronunciation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            )),
        const SizedBox(height: 16),
        Text(word.definitionCn,
            style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(word.definitionEn,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
        if (word.examples.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ExpandableSection(
            title: '例句',
            count: word.examples.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: word.examples.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.en,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        )),
                    Text(e.cn,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
        if (word.rootAnalysis != null) ...[
          const SizedBox(height: 12),
          _ExpandableSection(
            title: '词根',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (word.rootAnalysis!.overallMeaning != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('整体含义：${word.rootAnalysis!.overallMeaning}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ),
                ...word.rootAnalysis!.components.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(c.part,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                            )),
                      ),
                      const SizedBox(width: 8),
                      Text(c.meaning,
                          style: theme.textTheme.bodySmall),
                      const SizedBox(width: 4),
                      Text('(${c.origin})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          )),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
        if (word.collocations.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ExpandableSection(
            title: '搭配',
            count: word.collocations.length,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: word.collocations.map((c) => Chip(
                avatar: Text(c.phrase,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                label: Text(c.meaning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final int? count;
  final Widget child;

  const _ExpandableSection({
    required this.title,
    this.count,
    required this.child,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.count != null
                      ? '${widget.title} (${widget.count})'
                      : widget.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: widget.child,
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
