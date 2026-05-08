import 'package:flutter/material.dart';
import 'free_play_view.dart';
import 'practice_view.dart';

enum _ChordPage { hub, freePlay, practice }

class ChordHubView extends StatefulWidget {
  const ChordHubView({super.key});

  @override
  State<ChordHubView> createState() => _ChordHubViewState();
}

class _ChordHubViewState extends State<ChordHubView> {
  _ChordPage _page = _ChordPage.hub;

  @override
  Widget build(BuildContext context) {
    if (_page == _ChordPage.freePlay) {
      return FreePlayView(onBack: () => setState(() => _page = _ChordPage.hub));
    }
    if (_page == _ChordPage.practice) {
      return PracticeView(onBack: () => setState(() => _page = _ChordPage.hub));
    }
    return _buildHub(context);
  }

  Widget _buildHub(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('弦', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '自由弹奏或和弦练耳',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Column(
                children: [
                  _EntryCard(
                    icon: Icons.piano,
                    title: '弹奏模式',
                    subtitle: 'Free Play',
                    description: '点击钢琴键自由弹奏',
                    onTap: () => setState(() => _page = _ChordPage.freePlay),
                  ),
                  const SizedBox(height: 16),
                  _EntryCard(
                    icon: Icons.hearing,
                    title: '练习模式',
                    subtitle: 'Practice',
                    description: '聆听 → 辨认 → 验证 · 12 种和弦类型',
                    onTap: () => setState(() => _page = _ChordPage.practice),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _EntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: theme.textTheme.titleLarge),
                        const SizedBox(width: 10),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
