import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../word/providers/word_provider.dart';


class VocabListView extends StatelessWidget {
  final VoidCallback? onNavigateToWord;

  const VocabListView({super.key, this.onNavigateToWord});

  @override
  Widget build(BuildContext context) {
    return Consumer<WordProvider>(
      builder: (context, provider, _) {
        final words = provider.allWords;
        final currentWord = provider.currentWord;
        final theme = Theme.of(context);

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('单词本', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${words.length} 个词条',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final entry = words[index];
                    final isActive = currentWord?.word == entry.word;

                    return Card(
                      color: isActive
                          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                          : null,
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              entry.word,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.partOfSpeech,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          entry.definitionCn,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: entry.difficulty != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.difficulty!,
                                  style: theme.textTheme.bodySmall,
                                ),
                              )
                            : null,
                        onTap: () {
                          provider.selectWord(entry);
                          onNavigateToWord?.call();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
