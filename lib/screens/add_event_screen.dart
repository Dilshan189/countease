import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';

class AddEventScreen extends StatefulWidget {
  final Event? eventToEdit;

  const AddEventScreen({super.key, this.eventToEdit});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eventController = Get.find<EventController>();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _selectedTime;
  EventType _selectedType = EventType.custom;
  bool _repeatYearly = false;
  bool _notificationEnabled = true;
  bool _isLoading = false;

  bool get _isEditing => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    final event = widget.eventToEdit!;
    _titleController.text = event.title;
    _descriptionController.text = event.description ?? '';
    _selectedDate = event.eventDate;
    _selectedTime = event.eventTime;
    _selectedType = event.type;
    _repeatYearly = event.repeatYearly;
    _notificationEnabled = event.notificationEnabled;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Event' : 'Add New Event',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Details Title
              _buildSectionTitle('Event Details', theme),
              const SizedBox(height: 12),

              // Title input
              TextFormField(
                controller: _titleController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'Enter event name...',
                  prefixIcon: const Icon(Icons.event_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Description input
              TextFormField(
                controller: _descriptionController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add a description...',
                  prefixIcon: const Icon(Icons.description_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Event Type Title
              _buildSectionTitle('Event Category', theme),
              const SizedBox(height: 12),
              _buildEventTypeCards(theme, isDark),
              const SizedBox(height: 24),

              // Event Date & Time
              _buildSectionTitle('Date & Time', theme),
              const SizedBox(height: 12),
              _buildDateTile(theme, isDark),
              const SizedBox(height: 10),
              _buildTimeTile(theme, isDark),
              const SizedBox(height: 24),

              // Options
              _buildSectionTitle('Preferences', theme),
              const SizedBox(height: 12),
              _buildOptionsBox(theme, isDark),
              const SizedBox(height: 36),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedCustomButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: _isEditing ? 'Save Changes' : 'Create Event',
                      onPressed: _saveEvent,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryIndigo,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEventTypeCards(ThemeData theme, bool isDark) {
    return Column(
      children: EventType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = type;
              if (type == EventType.birthday || type == EventType.poya) {
                _repeatYearly = true;
              } else {
                _repeatYearly = false;
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isSelected ? _getGradient(type) : null,
              color: isSelected
                  ? null
                  : (isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _getGradient(type).colors.first.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primaryIndigo.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getTypeEmoji(type),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeName(type),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTypeDescription(type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTile(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryIndigo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryIndigo, size: 20),
        ),
        title: Text(
          'Select Date',
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('EEEE, MMMM d, y').format(_selectedDate),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryIndigo,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildTimeTile(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.access_time_rounded, color: AppColors.accent, size: 20),
        ),
        title: Text(
          'Select Time (Optional)',
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _selectedTime != null ? _selectedTime!.format(context) : 'No time set (All day)',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: _selectedTime != null ? AppColors.accent : Colors.grey,
          ),
        ),
        trailing: _selectedTime != null
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () => setState(() => _selectedTime = null),
              )
            : const Icon(Icons.chevron_right_rounded),
        onTap: _selectTime,
      ),
    );
  }

  Widget _buildOptionsBox(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Repeat Yearly'),
            subtitle: const Text('Resets target date automatically every year'),
            value: _repeatYearly,
            onChanged: (bool value) => setState(() => _repeatYearly = value),
            secondary: const Icon(Icons.repeat_rounded),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable Alerts'),
            subtitle: const Text('Get push notifications before target time'),
            value: _notificationEnabled,
            onChanged: (bool value) => setState(() => _notificationEnabled = value),
            secondary: const Icon(Icons.notifications_active_rounded),
          ),
        ],
      ),
    );
  }

  String _getTypeEmoji(EventType type) {
    switch (type) {
      case EventType.birthday:
        return '🎂';
      case EventType.exam:
        return '📚';
      case EventType.poya:
        return '🌕';
      case EventType.custom:
        return '📅';
    }
  }

  String _getTypeName(EventType type) {
    switch (type) {
      case EventType.birthday:
        return 'Birthday';
      case EventType.exam:
        return 'Exam';
      case EventType.poya:
        return 'Poya';
      case EventType.custom:
        return 'Custom Event';
    }
  }

  String _getTypeDescription(EventType type) {
    switch (type) {
      case EventType.birthday:
        return 'Yearly celebrative milestone';
      case EventType.exam:
        return 'Tests, reviews, and academic tasks';
      case EventType.poya:
        return 'Buddhist Poya holiday schedule';
      case EventType.custom:
        return 'Any other countdown track';
    }
  }

  LinearGradient _getGradient(EventType type) {
    switch (type) {
      case EventType.birthday:
        return AppGradients.birthdayGradient;
      case EventType.exam:
        return AppGradients.examGradient;
      case EventType.poya:
        return AppGradients.poyaGradient;
      case EventType.custom:
        return AppGradients.customGradient;
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final event = Event(
        id: _isEditing ? widget.eventToEdit!.id : _eventController.generateEventId(),
        title: _titleController.text.trim(),
        eventDate: _selectedDate,
        eventTime: _selectedTime,
        type: _selectedType,
        repeatYearly: _repeatYearly,
        notificationEnabled: _notificationEnabled,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        createdAt: _isEditing ? widget.eventToEdit!.createdAt : DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await _eventController.updateEvent(event);
      } else {
        success = await _eventController.addEvent(event);
      }

      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          _isEditing ? 'Countdown saved' : 'Countdown active!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not save countdown: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
