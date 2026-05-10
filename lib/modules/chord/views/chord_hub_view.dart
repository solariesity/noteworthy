import 'package:flutter/material.dart';
import '../../../core/widgets/entry_card.dart';
import 'free_play_view.dart';
import 'practice_view.dart';
import 'interval_practice_view.dart';
import 'progression_reveal_view.dart';

enum _ChordPage { hub, freePlay, practice, intervalPractice, progressionReveal }

class ChordHubView extends StatefulWidget {
  const ChordHubView({super.key});

  @override
  State<ChordHubView> createState() => _ChordHubViewState();
}

class _ChordHubViewState extends State<ChordHubView> {
  _ChordPage _page = _ChordPage.hub;

  void _backToHub() => setState(() => _page = _ChordPage.hub);
  void _goto(_ChordPage page) => setState(() => _page = page);

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _ChordPage.freePlay => FreePlayView(onBack: _backToHub),
      _ChordPage.practice => PracticeView(onBack: _backToHub),
      _ChordPage.intervalPractice => IntervalPracticeView(onBack: _backToHub),
      _ChordPage.progressionReveal => ProgressionRevealView(onBack: _backToHub),
      _ChordPage.hub => _buildHub(context),
    };
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
            Text('弹奏 · 练耳 · 音程 · 进行', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  EntryCard(
                    icon: Icons.piano,
                    title: '弹奏模式',
                    subtitle: 'Free Play',
                    description: '点击钢琴键自由弹奏',
                    onTap: () => _goto(_ChordPage.freePlay),
                  ),
                  const SizedBox(height: 16),
                  EntryCard(
                    icon: Icons.hearing,
                    title: '和弦辨识',
                    subtitle: 'Practice',
                    description: '聆听 → 辨认 → 验证 · 12 种和弦类型',
                    onTap: () => _goto(_ChordPage.practice),
                  ),
                  const SizedBox(height: 16),
                  EntryCard(
                    icon: Icons.arrow_upward,
                    title: '音程练习',
                    subtitle: 'Interval',
                    description: '听参考音 → 辨第二个音 · 耳力训练',
                    onTap: () => _goto(_ChordPage.intervalPractice),
                  ),
                  const SizedBox(height: 16),
                  EntryCard(
                    icon: Icons.queue_music,
                    title: '和弦进行',
                    subtitle: 'Progression',
                    description: '听根音 → 和弦序列 → 揭晓答案',
                    onTap: () => _goto(_ChordPage.progressionReveal),
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
