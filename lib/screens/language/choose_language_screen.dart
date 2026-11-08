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
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_center.dart';

/// Grid of languages. Continue → choose level.
class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  late String? _selected = context.read<SettingsProvider>().languageCode;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ContentRepository>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: context.canPop(),
        title: const Text('Choose a language'),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pagePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What do you want to learn?',
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Maxaad rabtaa inaad barato?',
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AsyncContent<List<Language>>(
                  load: repo.getLanguages,
                  isEmpty: (l) => l.isEmpty,
                  emptyTitle: 'No languages available',
                  emptyIcon: Icons.language_rounded,
                  builder: (context, languages, _) => LayoutBuilder(
                    builder: (context, c) => GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: responsiveColumns(c.maxWidth),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 172,
                      ),
                      itemCount: languages.length,
                      itemBuilder: (_, i) {
                        final lang = languages[i];
                        return _LanguageCard(
                          language: lang,
                          selected: lang.code == _selected,
                          onTap: lang.isAvailable
                              ? () => setState(() => _selected = lang.code)
                              : () => context.showSnack(
                                  '${lang.name} is coming soon!',
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: _selected == null
                      ? null
                      : () => context.pushNamed(
                          AppRoutes.chooseLevel,
                          queryParameters: {'lang': _selected!},
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final Language language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.03 : 1,
      duration: const Duration(milliseconds: 200),
      child: Opacity(
        opacity: language.isAvailable ? 1 : 0.55,
        child: AppCard(
          onTap: onTap,
          borderColor: selected ? context.colors.primary : null,
          child: Stack(
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(language.flag, style: const TextStyle(fontSize: 44)),
                      const SizedBox(height: 10),
                      Text(
                        language.name,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        language.nativeName,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      if (!language.isAvailable) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Coming soon',
                          style: context.text.labelSmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: context.colors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
