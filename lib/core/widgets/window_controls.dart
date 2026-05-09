import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowControls extends StatefulWidget {
  const WindowControls({super.key});

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((v) => setState(() => _maximized = v));
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Button(
          icon: Icons.minimize,
          tooltip: 'Minimize',
          onTap: () => windowManager.minimize(),
          foreground: fg,
        ),
        _Button(
          icon: _maximized ? Icons.filter_none : Icons.crop_square,
          tooltip: _maximized ? 'Restore' : 'Maximize',
          onTap: () => _maximized ? windowManager.unmaximize() : windowManager.maximize(),
          foreground: fg,
        ),
        _Button(
          icon: Icons.close,
          tooltip: 'Close',
          onTap: () => windowManager.close(),
          foreground: fg,
          hoverColor: Colors.red.withValues(alpha: 0.9),
        ),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color foreground;
  final Color? hoverColor;

  const _Button({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.foreground,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 32,
          child: Icon(icon, size: 14, color: foreground),
        ),
      ),
    );
  }
}
