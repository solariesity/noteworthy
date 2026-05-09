import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'modules/word/services/word_service.dart';
import 'modules/word/providers/word_provider.dart';
import 'modules/chord/services/chord_generator.dart';
import 'modules/chord/providers/chord_provider.dart';
import 'midi/services/midi_scheduler.dart';
import 'midi/services/midi_player.dart';
import 'midi/midi_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setMinimumSize(const Size(900, 600));

  final wordService = WordService();
  await wordService.initialize();

  final midiPlayer = createMidiPlayer();
  await midiPlayer.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<MidiPlayer>.value(value: midiPlayer),
        ChangeNotifierProvider(
          create: (_) => WordProvider(wordService)..nextWord(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChordProvider(
            ChordGenerator(),
            MidiScheduler(midiPlayer),
          )..nextChord(),
        ),
      ],
      child: const NoteworthyApp(),
    ),
  );
}
