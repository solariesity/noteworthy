import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/entry_card.dart';
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

  void _goto(_WordPage page) => setState(() => _page = page);

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _WordPage.wordLearning => WordCardView(
          key: const ValueKey('wordLearning'),
          onBack: () => _goto(_WordPage.hub),
        ),
      _WordPage.planList => PlanListView(
          key: const ValueKey('planList'),
          onBack: () => _goto(_WordPage.hub),
          onStartLearning: () => _goto(_WordPage.wordLearning),
          onOpenPlan: (planId) {
            _selectedPlanId = planId;
            _goto(_WordPage.planDetail);
          },
        ),
      _WordPage.planDetail when _selectedPlanId != null => PlanDetailView(
          key: ValueKey('planDetail_$_selectedPlanId'),
          planId: _selectedPlanId!,
          onBack: () => _goto(_WordPage.planList),
          onStartLearning: () => _goto(_WordPage.wordLearning),
        ),
      _ => _buildHub(context),
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
            Text('词', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('计划 · 学习 · 窗口', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  EntryCard(
                    icon: Icons.calendar_today,
                    title: '计划选择',
                    subtitle: 'Plan',
                    description: '创建、管理并导入学习计划',
                    onTap: () => _goto(_WordPage.planList),
                  ),
                  const SizedBox(height: 16),
                  EntryCard(
                    icon: Icons.menu_book,
                    title: '单词学习',
                    subtitle: 'Learn',
                    description: '浏览单词卡片，扩展词汇量',
                    onTap: _enterWordLearning,
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
      _goto(_WordPage.wordLearning);
      return;
    }

    final planProvider = context.read<PlanProvider>();
    final activeId = planProvider.activePlanId;
    if (activeId != null) {
      planProvider.loadPlan(activeId).then((plan) {
        if (plan != null && mounted) {
          planProvider.startLearning(plan, wordProvider);
          _goto(_WordPage.wordLearning);
        }
      });
    } else {
      _goto(_WordPage.planList);
    }
  }
}
