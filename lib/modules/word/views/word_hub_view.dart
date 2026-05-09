import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../providers/plan_provider.dart';
import 'word_card_view.dart';
import 'plan_list_view.dart';
import 'plan_detail_view.dart';

enum _WordPage { hub, wordLearning, planList, planDetail }

class WordHubView extends StatefulWidget {
  const WordHubView({super.key});

  @override
  State<WordHubView> createState() => _WordHubViewState();
}

class _WordHubViewState extends State<WordHubView> {
  _WordPage _page = _WordPage.hub;
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    if (_page == _WordPage.wordLearning) {
      return WordCardView(
        key: const ValueKey('wordLearning'),
        onBack: () => setState(() => _page = _WordPage.hub),
      );
    }
    if (_page == _WordPage.planList) {
      return PlanListView(
        key: const ValueKey('planList'),
        onBack: () => setState(() => _page = _WordPage.hub),
        onStartLearning: () => setState(() => _page = _WordPage.wordLearning),
        onOpenPlan: (planId) {
          _selectedPlanId = planId;
          setState(() => _page = _WordPage.planDetail);
        },
      );
    }
    if (_page == _WordPage.planDetail && _selectedPlanId != null) {
      return PlanDetailView(
        key: ValueKey('planDetail_$_selectedPlanId'),
        planId: _selectedPlanId!,
        onBack: () => setState(() => _page = _WordPage.planList),
        onStartLearning: () => setState(() => _page = _WordPage.wordLearning),
      );
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
            Text('词', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '计划 · 学习 · 窗口',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _EntryCard(
                    icon: Icons.calendar_today,
                    title: '计划选择',
                    subtitle: 'Plan',
                    description: '创建、管理并导入学习计划',
                    onTap: () => setState(() => _page = _WordPage.planList),
                  ),
                  const SizedBox(height: 16),
                  _EntryCard(
                    icon: Icons.menu_book,
                    title: '单词学习',
                    subtitle: 'Learn',
                    description: '浏览单词卡片，扩展词汇量',
                    onTap: () => _enterWordLearning(),
                  ),
                  const SizedBox(height: 16),
                  _EntryCard(
                    icon: Icons.window,
                    title: '窗口模式',
                    subtitle: 'Window Mode',
                    description: '悬浮窗或分屏学习模式',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _enterWordLearning() {
    final wordProvider = context.read<WordProvider>();
    if (wordProvider.isPlanMode) {
      setState(() => _page = _WordPage.wordLearning);
      return;
    }

    final planProvider = context.read<PlanProvider>();
    final activeId = planProvider.activePlanId;
    if (activeId != null) {
      planProvider.loadPlan(activeId).then((plan) {
        if (plan != null && mounted) {
          planProvider.startLearning(plan, wordProvider);
          setState(() => _page = _WordPage.wordLearning);
        }
      });
    } else {
      setState(() => _page = _WordPage.planList);
    }
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
