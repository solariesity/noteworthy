import 'package:flutter/material.dart';

/// 答题反馈区：✓/✗ 图标 + "正确！/不对哦" 文案 + 可选的额外内容（答案、解析等）。
class FeedbackArea extends StatelessWidget {
  final bool isCorrect;
  final List<Widget> extra;

  const FeedbackArea({
    super.key,
    required this.isCorrect,
    this.extra = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? Colors.green : Colors.red;

    return Column(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          size: 36,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          isCorrect ? '正确！' : '不对哦',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        ...extra,
      ],
    );
  }
}
