import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'modules/word/services/word_service.dart';
import 'modules/word/providers/word_provider.dart';
import 'modules/word/providers/plan_provider.dart';
import 'modules/chord/services/chord_generator.dart';
import 'modules/chord/providers/chord_provider.dart';
import 'modules/chord/providers/interval_practice_provider.dart';
import 'modules/chord/providers/progression_reveal_provider.dart';
import 'midi/services/midi_scheduler.dart';
import 'midi/services/midi_player.dart';
import 'midi/midi_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setMinimumSize(const Size(900, 600));
  }

  final wordService = WordService();
  await wordService.initialize();

  final planProvider = PlanProvider();
  await planProvider.initialize();

  final midiPlayer = createMidiPlayer();
  await midiPlayer.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<MidiPlayer>.value(value: midiPlayer),
        ChangeNotifierProvider(
          create: (_) => WordProvider(wordService)..nextWord(),
        ),
        ChangeNotifierProvider.value(value: planProvider),
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
