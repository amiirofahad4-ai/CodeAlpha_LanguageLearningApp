import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/language.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/section_card.dart';
import '../../widgets/user_avatar.dart';

/// Account info and settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final progress = context.watch<ProgressProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            0,
            AppConstants.pagePadding,
            32,
          ),
          children: [
            // Header
            AppCard(
              child: Row(
                children: [
                  UserAvatar(user: user, radius: 34),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest',
                          style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '⚡ ${progress.xp} XP  ·  🔥 ${progress.streak} ${progress.streak == 1 ? 'day' : 'days'}',
                          style: context.text.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit name',
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => _editName(context, user?.name ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Learning'),
            _SettingsGroup(
              children: [
                _LanguageTile(code: settings.languageCode),
                _tile(
                  context,
                  icon: Icons.signal_cellular_alt_rounded,
                  color: AppColors.secondary,
                  title: 'Level',
                  value: settings.level.label,
                  onTap: () => _pickLevel(context, settings),
                ),
                _tile(
                  context,
                  icon: Icons.flag_rounded,
                  color: AppColors.streak,
                  title: 'Daily goal',
                  value: '${settings.dailyGoal} XP',
                  onTap: () => _pickGoal(context, settings),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Preferences'),
            _SettingsGroup(
              children: [
                SwitchListTile(
                  secondary: _iconBox(
                    Icons.notifications_rounded,
                    AppColors.sky,
                  ),
                  title: const Text('Daily reminder'),
                  value: settings.remindersEnabled,
                  onChanged: settings.setRemindersEnabled,
                ),
                _tile(
                  context,
                  icon: Icons.schedule_rounded,
                  color: AppColors.purple,
                  title: 'Reminder time',
                  value: settings.reminderTime.format(context),
                  enabled: settings.remindersEnabled,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: settings.reminderTime,
                    );
                    if (time != null) await settings.setReminderTime(time);
                  },
                ),
                SwitchListTile(
                  secondary: _iconBox(
                    Icons.dark_mode_rounded,
                    AppColors.textSecondary,
                  ),
                  title: const Text('Dark mode'),
                  value: context.isDark,
                  onChanged: (on) => settings.setThemeMode(
                    on ? ThemeMode.dark : ThemeMode.light,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsGroup(
              children: [
                ListTile(
                  leading: _iconBox(Icons.logout_rounded, AppColors.error),
                  title: const Text(
                    'Log out',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () => _logout(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _iconBox(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color, size: 20),
  );

  static Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      enabled: enabled,
      leading: _iconBox(icon, color),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }

  /// Simple list dialog that returns the chosen value.
  static Future<T?> _choose<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required T current,
    required String Function(T) label,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: [
          for (final o in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, o),
              child: Row(
                children: [
                  Expanded(child: Text(label(o))),
                  if (o == current)
                    Icon(Icons.check_rounded, color: ctx.colors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickLevel(BuildContext context, SettingsProvider s) async {
    final level = await _choose<LanguageLevel>(
      context,
      title: 'Your level',
      options: LanguageLevel.values,
      current: s.level,
      label: (l) => '${l.label} · ${l.somaliLabel}',
    );
    if (level != null) await s.setLevel(level);
  }

  Future<void> _pickGoal(BuildContext context, SettingsProvider s) async {
    final goal = await _choose<int>(
      context,
      title: 'Daily goal',
      options: AppConstants.dailyGoalOptions,
      current: s.dailyGoal,
      label: (g) => switch (g) {
        10 => '10 XP · Casual',
        20 => '20 XP · Regular',
        30 => '30 XP · Serious',
        _ => '$g XP · Intense',
      },
    );
    if (goal != null) await s.setDailyGoal(goal);
  }

  Future<void> _editName(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.length < 2 || !context.mounted) return;
    final error = await context.read<AuthProvider>().updateName(name);
    if (context.mounted) {
      context.showSnack(error ?? 'Name updated', isError: error != null);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Your progress is saved to your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    // The router redirect sends the user to the login screen.
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }
}

/// Card wrapping a group of settings rows with dividers.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

/// Shows the current language (loaded from the repository).
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.code});
  final String? code;

  @override
  Widget build(BuildContext context) {
    void open() => context.pushNamed(AppRoutes.chooseLanguage);
    if (code == null) {
      return ListTile(
        leading: ProfileScreen._iconBox(
          Icons.language_rounded,
          AppColors.primary,
        ),
        title: const Text('Language'),
        trailing: const Text('Choose'),
        onTap: open,
      );
    }
    return AsyncContent<Language?>(
      key: ValueKey(code),
      compact: true,
      load: () => context.read<ContentRepository>().getLanguage(code!),
      loading: const ListTile(title: Text('Language'), trailing: Text('…')),
      builder: (context, lang, _) => ProfileScreen._tile(
        context,
        icon: Icons.language_rounded,
        color: AppColors.primary,
        title: 'Language',
        value: lang == null ? code! : '${lang.flag} ${lang.name}',
        onTap: open,
      ),
    );
  }
}
