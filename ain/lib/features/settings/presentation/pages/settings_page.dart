import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/theme/app_colors.dart';
import 'package:incident_report_app/core/services/settings_service.dart';

class SettingsPage extends StatelessWidget {
  final SettingsService settingsService = Get.find<SettingsService>();

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Apparence',
            [
              _buildThemeModeSwitch(context),
              _buildColorOptions(context),
            ],
          ),
          _buildSection(
            context,
            'Notifications',
            [
              _buildNotificationSwitch(context),
            ],
          ),
          _buildSection(
            context,
            'Sécurité',
            [
              _buildBiometricSwitch(context),
            ],
          ),
          _buildSection(
            context,
            'Langue',
            [
              _buildLanguageOptions(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildThemeModeSwitch(BuildContext context) {
    return Obx(() => SwitchListTile(
          title: const Text('Mode sombre'),
          value: settingsService.settings.value.isDarkMode,
          onChanged: (value) {
            settingsService.toggleDarkMode();
          },
        ));
  }

  Widget _buildColorOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Couleur principale'),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildColorOption(context, 'Bleu', AppColors.primary),
              _buildColorOption(context, 'Vert', AppColors.success),
              _buildColorOption(context, 'Orange', AppColors.warning),
              _buildColorOption(context, 'Rouge', AppColors.error),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorOption(BuildContext context, String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => settingsService.changeThemeColor(name),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch(BuildContext context) {
    return Obx(() => SwitchListTile(
          title: const Text('Notifications'),
          value: settingsService.settings.value.isNotificationsEnabled,
          onChanged: (value) {
            settingsService.toggleNotifications();
          },
        ));
  }

  Widget _buildBiometricSwitch(BuildContext context) {
    return Obx(() => SwitchListTile(
          title: const Text('Authentification biométrique'),
          value: settingsService.settings.value.isBiometricEnabled,
          onChanged: (value) {
            settingsService.toggleBiometricAuth();
          },
        ));
  }

  Widget _buildLanguageOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Français'),
          trailing: Obx(() => settingsService.settings.value.language == 'fr'
              ? const Icon(Icons.check)
              : const SizedBox.shrink()),
          onTap: () => settingsService.changeLanguage('fr'),
        ),
        ListTile(
          title: const Text('English'),
          trailing: Obx(() => settingsService.settings.value.language == 'en'
              ? const Icon(Icons.check)
              : const SizedBox.shrink()),
          onTap: () => settingsService.changeLanguage('en'),
        ),
      ],
    );
  }
} 