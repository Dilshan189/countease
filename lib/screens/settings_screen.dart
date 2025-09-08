import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';
import '../controllers/event_controller.dart';
import '../widgets/custom_button.dart';

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
        'Test Notification',
        'Test notification sent successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send test notification: $e',
        snackPosition: SnackPosition.BOTTOM,
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance', theme),
              const SizedBox(height: 16),
              _buildAppearanceSettings(settingsController, theme),

              const SizedBox(height: 32),

              // Notifications Section
              _buildSectionHeader('Notifications', theme),
              const SizedBox(height: 16),
              _buildNotificationSettings(settingsController, theme),

              const SizedBox(height: 32),

              // Data Management Section
              _buildSectionHeader('Data Management', theme),
              const SizedBox(height: 16),
              _buildDataManagementSettings(eventController, theme),

              const SizedBox(height: 32),

              // App Information Section
              _buildSectionHeader('App Information', theme),
              const SizedBox(height: 16),
              _buildAppInfoSettings(theme),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAppearanceSettings(
    SettingsController controller,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark themes'),
            value: controller.darkMode,
            onChanged: controller.setDarkMode,
            secondary: Icon(
              controller.darkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(
    SettingsController controller,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminders about your events'),
            value: controller.notificationsEnabled,
            onChanged: controller.setNotificationsEnabled,
            secondary: Icon(
              controller.notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: theme.colorScheme.primary,
            ),
          ),
          if (controller.notificationsEnabled) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Test Notification'),
              subtitle: const Text('Send a test notification'),
              leading: Icon(Icons.send, color: theme.colorScheme.primary),
              trailing: controller.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: controller.isLoading ? null : controller.testNotification,
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Notification Schedule'),
              subtitle: const Text(
                'Events notify 1 week, 1 day before, and on the day',
              ),
              leading: Icon(Icons.schedule, color: theme.colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataManagementSettings(
    EventController eventController,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Export all events and settings'),
            leading: Icon(Icons.download, color: theme.colorScheme.primary),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showExportDialog(eventController),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Import Data'),
            subtitle: const Text('Import events from backup'),
            leading: Icon(Icons.upload, color: theme.colorScheme.primary),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showImportDialog(eventController),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all events and reset app'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showClearDataDialog(eventController),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSettings(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('CountEase v1.0.0'),
            leading: Icon(Icons.info, color: theme.colorScheme.primary),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('Learn more about CountEase'),
            leading: Icon(Icons.help, color: theme.colorScheme.primary),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAboutDialog(),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            leading: Icon(Icons.privacy_tip, color: theme.colorScheme.primary),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
        title: const Text('Export Data'),
        content: const Text(
          'This will export all your events and settings. '
          'The exported data will be copied to your clipboard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportData(eventController);
            },
            child: const Text('Export'),
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
        title: const Text('Import Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste your exported data below. This will replace all current data.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Paste exported data here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _importData(eventController, textController.text);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(EventController eventController) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all events, settings, and app data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllData(eventController);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('About CountEase'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CountEase is a beautiful countdown app that helps you track '
              'important events like birthdays, exams, and special occasions.',
            ),
            SizedBox(height: 16),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Real-time countdown timers'),
            Text('• Event notifications'),
            Text('• Multiple event types'),
            Text('• Dark/light themes'),
            Text('• Data backup & restore'),
            SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Storage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'All your event data is stored locally on your device. '
                'We do not collect, store, or transmit any personal information.',
              ),
              SizedBox(height: 16),
              Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Notification permissions are used only to remind you about your events. '
                'No data is shared with third parties.',
              ),
              SizedBox(height: 16),
              Text(
                'Data Export',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You can export your data at any time. Exported data is under your '
                'complete control and is not shared with us.',
              ),
            ],
          ),
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
      final data = eventController.exportEvents();
      final jsonString = data.toString();

      // In a real app, you would use share_plus plugin or file picker
      // For now, we'll show the data in a dialog for copying
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: const Text('Exported Data'),
          content: SingleChildScrollView(child: SelectableText(jsonString)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      Get.snackbar(
        'Export Successful',
        'Data exported successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Failed to export data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _importData(EventController eventController, String data) {
    if (data.trim().isEmpty) {
      Get.snackbar(
        'Import Failed',
        'Please paste valid export data',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // In a real app, you would parse JSON properly
      Get.snackbar(
        'Import Notice',
        'Import functionality requires JSON parsing implementation',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Import Failed',
        'Failed to import data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _clearAllData(EventController eventController) async {
    try {
      await eventController.deleteAllEvents();
      await DatabaseService.setDarkMode(false);
      await DatabaseService.setNotificationsEnabled(true);

      Get.snackbar(
        'Data Cleared',
        'All data has been cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Clear Failed',
        'Failed to clear data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
