import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/main.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // APPEARANCE
          const _SectionHeader(title: 'Appearance'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDarkMode ? AppColors.warning : AppColors.secondary,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(isDarkMode ? 'Dark theme active' : 'Light theme active'),
              value: isDarkMode,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          const SizedBox(height: 24),

          // ACCOUNT
          const _SectionHeader(title: 'Account'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_rounded, color: AppColors.primary),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_rounded, color: AppColors.info),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.forgotPassword),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ABOUT
          const _SectionHeader(title: 'About'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.tertiary),
                  title: const Text('About Community Care Hub'),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.policy_rounded, color: AppColors.onSurfaceVariant),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () async {
                    final uri = Uri.parse('https://communitycarehub.app/privacy');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_rounded, color: AppColors.onSurfaceVariant),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () async {
                    final uri = Uri.parse('https://communitycarehub.app/terms');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.code_rounded, color: AppColors.onSurfaceVariant),
                  title: Text('Version'),
                  trailing: Text('1.0.0', style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // DANGER ZONE
          const _SectionHeader(title: 'Danger Zone'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.emergency),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.emergency)),
              onTap: () async {
                final confirmed = await context.showConfirmDialog(
                  title: 'Sign Out',
                  message: 'Are you sure you want to sign out?',
                  confirmText: 'Sign Out',
                  isDangerous: true,
                );
                if (confirmed == true) {
                  await ref.read(authActionsProvider).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                }
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Community Care Hub',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Community Care Hub. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'One Platform. One Community. One Coordinated Workflow.\n\n'
          'Community Care Hub unites food donation, blood requests, volunteering, '
          'and emergency response into a single mobile platform for community welfare.',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
