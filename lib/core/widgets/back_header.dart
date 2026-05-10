import 'package:flutter/material.dart';

/// 子页面顶部统一的"返回箭头 + 标题"行；标题可省略（仅返回按钮）。
class BackHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final String? title;
  final List<Widget> trailing;

  const BackHeader({
    super.key,
    this.onBack,
    this.title,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
          if (title != null) ...[
            const SizedBox(width: 8),
            Text(title!, style: Theme.of(context).textTheme.titleLarge),
          ],
          if (trailing.isNotEmpty) ...[
            const Spacer(),
            ...trailing,
          ],
        ],
      ),
    );
  }
}
