import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('设置', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 24),
              Text('主题颜色', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(themeAccents.length, (i) {
                      final selected = i == themeProvider.selectedIndex;
                      return GestureDetector(
                        onTap: () => themeProvider.selectAccent(i),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: themeAccents[i].color,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white, size: 22)
                              : null,
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 24),
              Consumer<ThemeProvider>(
                builder: (context, provider, _) {
                  return Wrap(
                    spacing: 6,
                    children: themeAccents.map((a) {
                      final selected = provider.selectedIndex ==
                          themeAccents.indexOf(a);
                      return FilterChip(
                        label: Text(a.name),
                        selected: selected,
                        onSelected: (_) => provider.selectAccent(
                            themeAccents.indexOf(a)),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
