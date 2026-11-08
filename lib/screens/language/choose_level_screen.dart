import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/language.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/state_views.dart';

/// Beginner / Intermediate / Advanced for the chosen language.
class ChooseLevelScreen extends StatefulWidget {
  const ChooseLevelScreen({super.key, required this.languageCode});

  final String? languageCode;

  @override
  State<ChooseLevelScreen> createState() => _ChooseLevelScreenState();
}

class _ChooseLevelScreenState extends State<ChooseLevelScreen> {
  late LanguageLevel _level = context.read<SettingsProvider>().level;
  bool _saving = false;

  Future<void> _save(String code) async {
    setState(() => _saving = true);
    await context.read<SettingsProvider>().setLanguage(code, _level);
    if (mounted) context.goNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.languageCode;
    return Scaffold(
      appBar: AppBar(title: const Text('Your level')),
      body: SafeArea(
        child: code == null
            ? const ErrorView(
                title: 'No language selected',
                message: 'Go back and choose a language first.',
              )
            : AsyncContent<Language?>(
                load: () => context.read<ContentRepository>().getLanguage(code),
                isEmpty: (l) => l == null,
                emptyTitle: 'Language not found',
                builder: (context, language, _) => _buildBody(language!),
              ),
      ),
    );
  }

  Widget _buildBody(Language language) {
    return ResponsiveCenter(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                Text(language.flag, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  'How well do you know ${language.name}?',
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Heerkaaga dooro',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                for (final level in LanguageLevel.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _LevelCard(
                      level: level,
                      selected: level == _level,
                      onTap: () => setState(() => _level = level),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PrimaryButton(
              label: 'Start learning',
              isLoading: _saving,
              onPressed: () => _save(language.code),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final LanguageLevel level;
  final bool selected;
  final VoidCallback onTap;

  static const _icons = {
    LanguageLevel.beginner: Icons.signal_cellular_alt_1_bar_rounded,
    LanguageLevel.intermediate: Icons.signal_cellular_alt_2_bar_rounded,
    LanguageLevel.advanced: Icons.signal_cellular_alt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = LevelBadge.colorOf(level);
    return AppCard(
      onTap: onTap,
      borderColor: selected ? context.colors.primary : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icons[level], color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${level.label} · ${level.somaliLabel}',
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  level.description,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              key: ValueKey(selected),
              color: selected
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
