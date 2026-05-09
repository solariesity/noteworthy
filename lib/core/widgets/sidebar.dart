import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import '../constants.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static void _startDrag() {
    if (Platform.isWindows) windowManager.startDragging();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => _startDrag(),
            child: const SizedBox(height: 16),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => _startDrag(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.music_note, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Noteworthy',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(indent: 12, endIndent: 12, height: 1),
          const SizedBox(height: 6),
          _NavItem(
            icon: Icons.home,
            label: '主页',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            icon: Icons.text_fields,
            label: '词',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            icon: Icons.piano,
            label: '弦',
            selected: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),
          _NavItem(
            icon: Icons.settings,
            label: '设置',
            selected: selectedIndex == 3,
            onTap: () => onChanged(3),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              appVersion,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: selected
                  ? Border(
                      left: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    )
                  : null,
              color: selected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
