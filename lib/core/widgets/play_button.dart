import 'package:flutter/material.dart';

/// 圆形大播放按钮：未播放显示 ▶，正在播放显示音波图标，伴随发光环。
class PlayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isPlaying;

  const PlayButton({
    super.key,
    required this.onPressed,
    required this.isPlaying,
  });

  static const _size = 80.0;
  static const _iconSize = 40.0;
  static const _glowBlur = 20.0;
  static const _glowSpread = 2.0;
  static const _glowAlpha = 0.4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillColor = isPlaying
        ? theme.colorScheme.primary
        : theme.colorScheme.primaryContainer;
    final iconColor = isPlaying
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onPrimaryContainer;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          boxShadow: [
            BoxShadow(
              color: fillColor.withValues(alpha: _glowAlpha),
              blurRadius: _glowBlur,
              spreadRadius: _glowSpread,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.graphic_eq : Icons.play_arrow,
          size: _iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
