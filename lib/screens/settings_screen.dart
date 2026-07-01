import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';
import '../controllers/event_controller.dart';
import '../theme/app_theme.dart';

class SettingsController extends GetxController {
  final RxBool _darkMode = false.obs;
  final RxBool _notificationsEnabled = true.obs;
  final RxBool _isLoading = false.obs;

  bool get darkMode => _darkMode.value;
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    _darkMode.value = DatabaseService.getDarkMode();
    _notificationsEnabled.value = DatabaseService.getNotificationsEnabled();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode.value = value;
    await DatabaseService.setDarkMode(value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled.value = value;
    await DatabaseService.setNotificationsEnabled(value);

    if (value) {
      final permissionGranted = await NotificationService.requestPermissions();
      if (permissionGranted) {
        await NotificationService.scheduleAllEventNotifications();
      }
    } else {
      await NotificationService.cancelAllNotifications();
    }
  }

  Future<void> testNotification() async {
    _isLoading.value = true;
    try {
      await NotificationService.showTestNotification();
      Get.snackbar(
        'Test Alert Sent',
        'Test notification popped successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Alert Error',
        'Could not trigger test alert: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put(SettingsController());
    final eventController = Get.find<EventController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & Config',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Setting Section
              _buildSectionHeader('Appearance Options', theme),
              const SizedBox(height: 12),
              _buildAppearanceSettings(settingsController, theme, isDark),
              const SizedBox(height: 24),

              // Notifications Settings Section
              _buildSectionHeader('Push Notifications', theme),
              const SizedBox(height: 12),
              _buildNotificationSettings(settingsController, theme, isDark),
              const SizedBox(height: 24),

              // Data backups Section
              _buildSectionHeader('Data Management', theme),
              const SizedBox(height: 12),
              _buildDataManagementSettings(eventController, theme, isDark),
              const SizedBox(height: 24),

              // App details section
              _buildSectionHeader('Application Info', theme),
              const SizedBox(height: 12),
              _buildAppInfoSettings(theme, isDark),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.primaryIndigo,
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings(
    SettingsController controller,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      decoration: AppDecorations.elevatedCard(isDark: isDark, borderRadius: 16),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode Dark theme'),
            subtitle: const Text('Reduces eye strain in low-light environments'),
            value: controller.darkMode,
            onChanged: controller.setDarkMode,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                controller.darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primaryIndigo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(
    SettingsController controller,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      decoration: AppDecorations.elevatedCard(isDark: isDark, borderRadius: 16),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Get alerts for upcoming milestones'),
            value: controller.notificationsEnabled,
            onChanged: controller.setNotificationsEnabled,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                controller.notificationsEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color: AppColors.accent,
              ),
            ),
          ),
          if (controller.notificationsEnabled) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Trigger Test Alert'),
              subtitle: const Text('Verify that alerts pop up on this device'),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_rounded, color: AppColors.success),
              ),
              trailing: controller.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              onTap: controller.isLoading ? null : controller.testNotification,
            ),
            const Divider(height: 1),
            const ListTile(
              title: Text('Schedule Layout'),
              subtitle: Text('Reminders trigger 1 week prior, 1 day prior, and on target day.'),
              leading: Icon(Icons.schedule_rounded),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataManagementSettings(
    EventController eventController,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      decoration: AppDecorations.elevatedCard(isDark: isDark, borderRadius: 16),
      child: Column(
        children: [
          ListTile(
            title: const Text('Export JSON Backup'),
            subtitle: const Text('Copy data package to system clipboard'),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.download_rounded, color: Colors.blue),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showExportDialog(eventController),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Import JSON Backup'),
            subtitle: const Text('Restore countdown list from copied data package'),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.upload_rounded, color: Colors.orange),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showImportDialog(eventController),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Reset All App Data', style: TextStyle(color: AppColors.danger)),
            subtitle: const Text('Permanently clear hive boxes and options'),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever_rounded, color: AppColors.danger),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showClearDataDialog(eventController),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSettings(ThemeData theme, bool isDark) {
    return Container(
      decoration: AppDecorations.elevatedCard(isDark: isDark, borderRadius: 16),
      child: Column(
        children: [
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('CountEase v1.0.0'),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline_rounded, color: Colors.purple),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('About CountEase'),
            subtitle: const Text('App details and credits'),
            leading: const Icon(Icons.help_outline_rounded),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAboutDialog(),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('Data usage details'),
            leading: const Icon(Icons.privacy_tip_rounded),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showPrivacyDialog(),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(EventController eventController) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Data'),
        content: const Text(
          'Export all current countdown records. '
          'Copy the raw data string to clipboard for backup purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportData(eventController);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Export & Copy'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(EventController eventController) {
    final textController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Import Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste the JSON data package below to restore event list.'),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Paste backup code...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _importData(eventController, textController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(EventController eventController) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Application?'),
        content: const Text(
          'This action will permanently delete all your countdown goals, '
          'notifications schedule, and local databases. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllData(eventController);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About CountEase'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CountEase is a premium milestones tracking application for mobile devices.'),
            SizedBox(height: 12),
            Text('• Stored in Hive database'),
            Text('• Triggered via notification service'),
            Text('• Designed in glassmorphic styles'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Data Privacy'),
        content: const Text(
          'We do not compile or upload any of your files or event list. All local databases '
          'remain exclusively on your hardware box.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportData(EventController eventController) {
    try {
      final jsonStr = json.encode(eventController.exportEvents());
      Clipboard.setData(ClipboardData(text: jsonStr));

      Get.snackbar(
        'Export Successful',
        'Data backup copied to clipboard!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Failed to construct backup string: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void _importData(EventController eventController, String data) async {
    if (data.trim().isEmpty) return;
    try {
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(json.decode(data.trim()));
      final success = await eventController.importEvents(decoded);
      if (success) {
        Get.snackbar(
          'Restore Complete',
          'Countdown list imported successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        throw Exception("Invalid data structure");
      }
    } catch (e) {
      Get.snackbar(
        'Restore Failed',
        'Could not import events. Verify raw string format.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void _clearAllData(EventController eventController) async {
    try {
      await eventController.deleteAllEvents();
      await DatabaseService.setDarkMode(false);
      await DatabaseService.setNotificationsEnabled(true);
      Get.changeThemeMode(ThemeMode.light);

      Get.snackbar(
        'System Reset',
        'All count downs and configurations wiped.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Reset Failed',
        'Wipe process encountered error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }
}
