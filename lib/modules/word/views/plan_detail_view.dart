import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/widgets/back_header.dart';
import '../providers/plan_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/word_provider.dart';
import '../models/study_plan.dart';

class PlanDetailView extends StatefulWidget {
  final String planId;
  final VoidCallback? onBack;
  final VoidCallback? onStartLearning;

  const PlanDetailView({super.key, required this.planId, this.onBack, this.onStartLearning});

  @override
  State<PlanDetailView> createState() => _PlanDetailViewState();
}

class _PlanDetailViewState extends State<PlanDetailView> {
  late Future<StudyPlan?> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = context.read<PlanProvider>().loadPlan(widget.planId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<StudyPlan?>(
      future: _planFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final plan = snapshot.data;
        if (plan == null) {
          return const Center(child: Text('计划未找到'));
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackHeader(
                  onBack: widget.onBack,
                  title: plan.name,
                  trailing: [
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _showEditDialog(plan);
                        } else if (action == 'delete') {
                          _showDeleteConfirm(plan);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('编辑计划',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface)),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('删除计划',
                              style: TextStyle(
                                  color: theme.colorScheme.error)),
                        ),
                      ],
                    ),
                  ],
                ),
                if (plan.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(plan.description, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 4),
                Text(
                  '${plan.words.length} 个词条',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: plan.words.isEmpty
                          ? null
                          : () {
                              context.read<PlanProvider>().startLearning(
                                plan,
                                context.read<WordProvider>(),
                              );
                              widget.onStartLearning?.call();
                            },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('开始学习'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _importWords(plan),
                      icon: const Icon(Icons.file_open, size: 18),
                      label: const Text('导入单词'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: plan.words.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '还没有词条',
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '点击「导入单词」添加词条',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final favProvider = context.read<FavoritesProvider>();
                            final pairs = plan.words.asMap().entries.toList();
                            // Favorited words first
                            pairs.sort((a, b) {
                              final aFav = favProvider.isFavorited(a.value.word);
                              final bFav = favProvider.isFavorited(b.value.word);
                              return bFav ? 1 : (aFav ? -1 : 0);
                            });

                            return ListView.builder(
                              itemCount: pairs.length,
                              itemBuilder: (context, index) {
                                final pair = pairs[index];
                                final originalIndex = pair.key;
                                final word = pair.value;
                                final favorited = favProvider.isFavorited(word.word);

                                return Card(
                                  child: ListTile(
                                    leading: favorited
                                        ? Icon(Icons.star,
                                            size: 18, color: Colors.amber.shade700)
                                        : null,
                                    title: Row(
                                      children: [
                                        Text(
                                          word.word,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          word.partOfSpeech,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      word.definitionCn,
                                      style: theme.textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: favorited
                                        ? null
                                        : IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: theme.colorScheme.error,
                                            ),
                                            onPressed: () {
                                              context.read<PlanProvider>().deleteWord(
                                                widget.planId,
                                                originalIndex,
                                              );
                                              _refresh();
                                            },
                                          ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _refresh() {
    setState(() {
      _planFuture = context.read<PlanProvider>().loadPlan(widget.planId);
    });
  }

  void _showEditDialog(StudyPlan plan) {
    final nameController = TextEditingController(text: plan.name);
    final descController = TextEditingController(text: plan.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('编辑计划',
            style: Theme.of(ctx).textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '计划名称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: '描述'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              context.read<PlanProvider>().updatePlanMeta(
                widget.planId,
                name,
                descController.text.trim(),
              );
              Navigator.pop(ctx);
              _refresh();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(StudyPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除计划',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text('确定要删除「${plan.name}」吗？\n此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<PlanProvider>().deletePlan(widget.planId);
              Navigator.pop(ctx);
              widget.onBack?.call();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _importWords(StudyPlan plan) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final file = result.files.first;
    if (file.path == null) return;

    final planProvider = context.read<PlanProvider>();
    final planName = plan.name;

    try {
      final content = await File(file.path!).readAsString();

      final added = file.name.endsWith('.csv')
          ? await planProvider.importFromCsv(widget.planId, content)
          : await planProvider.importFromJson(widget.planId, content);

      if (mounted) {
        _refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入完成：新增 $added 个词条到「$planName」')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败：$e')),
        );
      }
    }
  }
}
