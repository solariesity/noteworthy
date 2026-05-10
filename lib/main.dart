import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/shortcut_service.dart';
import 'app.dart';
import 'modules/word/services/word_service.dart';
import 'modules/word/providers/word_provider.dart';
import 'modules/word/providers/plan_provider.dart';
import 'modules/word/providers/favorites_provider.dart';
import 'modules/word/services/plan_storage.dart';
import 'modules/chord/services/chord_generator.dart';
import 'modules/chord/providers/chord_provider.dart';
import 'modules/chord/providers/interval_practice_provider.dart';
import 'modules/chord/providers/progression_reveal_provider.dart';
import 'modules/midi/services/midi_scheduler.dart';
import 'modules/midi/services/midi_player.dart';
import 'modules/midi/platform/noop_midi_player.dart'
    if (dart.library.ffi) 'modules/midi/platform/native_midi_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setMinimumSize(const Size(900, 600));
  }

  final wordService = WordService();
  await wordService.initialize();

  final planStorage = PlanStorage();

  final planProvider = PlanProvider(storage: planStorage);
  await planProvider.initialize();

  final favoritesProvider = FavoritesProvider(planStorage);
  await favoritesProvider.initialize();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final shortcutService = ShortcutService();
  await shortcutService.initialize();

  final midiPlayer = createNativeMidiPlayer();
  await midiPlayer.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<MidiPlayer>.value(value: midiPlayer),
        ChangeNotifierProvider(
          create: (_) => WordProvider(wordService)..nextWord(),
        ),
        ChangeNotifierProvider.value(value: planProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        Provider<ShortcutService>.value(value: shortcutService),
        ChangeNotifierProvider(
          create: (_) => ChordProvider(
            ChordGenerator(),
            MidiScheduler(midiPlayer),
          )..nextChord(),
        ),
        ChangeNotifierProvider(
          create: (_) => IntervalPracticeProvider(
            MidiScheduler(midiPlayer),
          )..nextQuestion(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressionRevealProvider(
            ChordGenerator(),
            MidiScheduler(midiPlayer),
          )..nextProgression(),
        ),
      ],
      child: const NoteworthyApp(),
    ),
  );
}
