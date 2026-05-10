import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/sidebar.dart';
import 'core/widgets/window_controls.dart';
import 'modules/home/views/home_view.dart';
import 'modules/word/views/word_hub_view.dart';
import 'modules/chord/views/chord_hub_view.dart';
import 'modules/settings/views/settings_view.dart';

double _fontScaleFromLevel(int level) => const [1.0, 1.12, 1.24, 1.36][level.clamp(0, 3)];

class NoteworthyApp extends StatelessWidget {
  const NoteworthyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final scale = _fontScaleFromLevel(themeProvider.fontSizeLevel);
        return MaterialApp(
          title: 'Noteworthy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme(themeProvider.accentColor, themeProvider.brightness, fontScale: scale),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Sidebar(
                selectedIndex: _selectedNav,
                onChanged: (i) => setState(() => _selectedNav = i),
              ),
              Expanded(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 44),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _buildPage(_selectedNav),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (Platform.isWindows) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 138, // leave room for window controls
              height: 48,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (_) => windowManager.startDragging(),
                child: const SizedBox.expand(),
              ),
            ),
            const Positioned(
              top: 0,
              right: 0,
              child: WindowControls(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    return switch (index) {
      0 => const HomeView(key: ValueKey('home')),
      1 => const WordHubView(key: ValueKey('word')),
      2 => const ChordHubView(key: ValueKey('chord')),
      _ => const SettingsView(key: ValueKey('settings')),
    };
  }
}
