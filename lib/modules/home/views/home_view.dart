import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../word/providers/word_provider.dart';

class _TimePeriod {
  final String greeting;
  final IconData icon;
  final Color color;
  const _TimePeriod(this.greeting, this.icon, this.color);
}

_TimePeriod _periodFromHour(int hour) {
  if (hour >= 5 && hour < 7)  return const _TimePeriod('清晨好', Icons.wb_twilight,  Color(0xFFF4A460));
  if (hour >= 7 && hour < 12) return const _TimePeriod('上午好', Icons.wb_sunny,    Color(0xFFFFB74D));
  if (hour >= 12 && hour < 17) return const _TimePeriod('下午好', Icons.wb_sunny,  Color(0xFFFFA726));
  if (hour >= 17 && hour < 19) return const _TimePeriod('傍晚好', Icons.wb_twilight,  Color(0xFFE57373));
  return const _TimePeriod('晚上好', Icons.nights_stay, Color(0xFF5C6BC0));
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = _periodFromHour(_now.hour);

    final words = context.read<WordProvider>().allWords;
    // 基于 dayOfYear 取模，实现"每日一词"确定性切换
    final dayOfYear = DateTime(_now.year, _now.month, _now.day)
        .difference(DateTime(_now.year, 1, 1))
        .inDays;
    final dailyWord = words.isNotEmpty ? words[dayOfYear % words.length] : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('主页', style: theme.textTheme.headlineMedium),
            const Spacer(flex: 1),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(period.icon, size: 120, color: period.color),
                  const SizedBox(height: 20),
                  Text(period.greeting, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(height: 48),
            if (dailyWord != null)
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('每日一词',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(dailyWord.word, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        dailyWord.pronunciation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(dailyWord.definitionCn,
                          style: theme.textTheme.bodyLarge),
                      if (dailyWord.examples.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          dailyWord.examples.first.en,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (dailyWord.collocations.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...dailyWord.collocations.map((c) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    c.phrase,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    c.meaning,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
