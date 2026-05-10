import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/shortcut_service.dart';
import '../../../core/constants.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shortcutService = context.read<ShortcutService>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('设置', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '主题 · 外观 · 快捷键',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('主题颜色', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Consumer<ThemeProvider>(
                            builder: (context, provider, _) {
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(themeAccents.length, (i) {
                                  final accent = themeAccents[i];
                                  final selected = i == provider.selectedIndex;
                                  return GestureDetector(
                                    onTap: () => provider.selectAccent(i),
                                    child: Tooltip(
                                      message: accent.name,
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: accent.color,
                                          shape: BoxShape.circle,
                                          border: selected
                                              ? Border.all(
                                                  color: theme.colorScheme.onSurface,
                                                  width: 3,
                                                )
                                              : null,
                                          boxShadow: selected
                                              ? [
                                                  BoxShadow(
                                                    color: accent.color
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 12,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (selected)
                                              const Icon(Icons.check,
                                                  color: Colors.white, size: 20),
                                            if (!selected)
                                              Icon(
                                                accent.icon,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('字体大小', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Consumer<ThemeProvider>(
                            builder: (context, provider, _) {
                              return Row(
                                children: [
                                  Text('小', style: theme.textTheme.bodySmall),
                                  Expanded(
                                    child: Slider(
                                      value: provider.fontSizeLevel.toDouble(),
                                      min: 0,
                                      max: 3,
                                      divisions: 3,
                                      onChanged: (v) => provider.setFontSizeLevel(v.round()),
                                    ),
                                  ),
                                  Text('大', style: theme.textTheme.bodySmall),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('全局快捷键', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  shortcutService.enabled
                                      ? '当前：${_hotKeyLabel(shortcutService.hotKey!)}'
                                      : '未设置',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _recordingShortcut(shortcutService),
                                icon: const Icon(Icons.keyboard, size: 18),
                                label: const Text('录制'),
                              ),
                              if (shortcutService.enabled)
                                TextButton(
                                  onPressed: () => shortcutService.clearShortcut(),
                                  child: const Text('清除'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '设置全局快捷键以快速呼出窗口',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('关于', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          const _AboutRow('应用名称', '词弦 Noteworthy'),
                          const _AboutRow('版本', kAppVersion),
                          const _AboutRow('框架', 'Flutter'),
                          const _AboutRow('平台', 'Windows Desktop'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text('仓库地址',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    )),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => launchUrl(
                                    Uri.parse('https://github.com/solariesity/noteworthy'),
                                  ),
                                  child: Text(
                                    'https://github.com/solariesity/noteworthy',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _hotKeyLabel(HotKey hotKey) {
    final parts = <String>[];
    final mods = hotKey.modifiers ?? [];
    if (mods.contains(HotKeyModifier.control)) parts.add('Ctrl');
    if (mods.contains(HotKeyModifier.alt)) parts.add('Alt');
    if (mods.contains(HotKeyModifier.shift)) parts.add('Shift');
    if (mods.contains(HotKeyModifier.meta)) parts.add('Win');
    parts.add(hotKey.key.keyLabel);
    return parts.join(' + ');
  }

  void _recordingShortcut(ShortcutService shortcutService) {
    showDialog(
      context: context,
      builder: (ctx) {
        HotKey? recorded;
        return StatefulBuilder(
          builder: (ctx, setDialog) {
            return AlertDialog(
              title: const Text('录制快捷键'),
              content: Focus(
                onKeyEvent: (_, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey != LogicalKeyboardKey.controlLeft &&
                      event.logicalKey != LogicalKeyboardKey.controlRight &&
                      event.logicalKey != LogicalKeyboardKey.altLeft &&
                      event.logicalKey != LogicalKeyboardKey.altRight &&
                      event.logicalKey != LogicalKeyboardKey.shiftLeft &&
                      event.logicalKey != LogicalKeyboardKey.shiftRight &&
                      event.logicalKey != LogicalKeyboardKey.metaLeft &&
                      event.logicalKey != LogicalKeyboardKey.metaRight) {
                    final modifiers = <HotKeyModifier>[];
                    if (HardwareKeyboard.instance.isControlPressed) {
                      modifiers.add(HotKeyModifier.control);
                    }
                    if (HardwareKeyboard.instance.isAltPressed) {
                      modifiers.add(HotKeyModifier.alt);
                    }
                    if (HardwareKeyboard.instance.isShiftPressed) {
                      modifiers.add(HotKeyModifier.shift);
                    }
                    if (HardwareKeyboard.instance.isMetaPressed) {
                      modifiers.add(HotKeyModifier.meta);
                    }
                    if (modifiers.isNotEmpty) {
                      recorded = HotKey(
                        key: event.logicalKey,
                        modifiers: modifiers,
                      );
                      setDialog(() {});
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(ctx).colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard,
                          size: 40,
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        recorded != null
                            ? _hotKeyLabel(recorded!)
                            : '按下快捷键组合...',
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '需要包含至少一个修饰键（Ctrl/Alt/Shift/Win）',
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: recorded != null
                      ? () {
                          shortcutService.setShortcut(recorded!);
                          Navigator.of(ctx).pop();
                        }
                      : null,
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
