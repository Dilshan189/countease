import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';
import '../widgets/custom_button.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'Add New Event'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Title
              _buildSectionTitle('Event Details', theme),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'Enter event name',
                  prefixIcon: Icon(Icons.event),
                  border: OutlineInputBorder(),
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

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add a description for your event',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 24),

              // Event Type
              _buildSectionTitle('Event Type', theme),
              const SizedBox(height: 16),
              _buildEventTypeSelector(theme),

              const SizedBox(height: 24),

              // Date Selection
              _buildSectionTitle('Event Date', theme),
              const SizedBox(height: 16),
              _buildDateSelector(theme),

              const SizedBox(height: 16),
              _buildTimeSelector(theme),

              const SizedBox(height: 24),

              // Options
              _buildSectionTitle('Options', theme),
              const SizedBox(height: 16),
              _buildOptionsSection(theme),

              const SizedBox(height: 32),

              // Action Buttons
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
                      text: _isEditing ? 'Update Event' : 'Create Event',
                      onPressed: _saveEvent,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),

              // Delete button for editing
              if (_isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: DangerButton(
                    text: 'Delete Event',
                    onPressed: _deleteEvent,
                    icon: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ],
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
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildEventTypeSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: EventType.values.map((type) {
          return RadioListTile<EventType>(
            title: Row(
              children: [
                Text(_getTypeEmoji(type), style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(_getTypeName(type)),
              ],
            ),
            subtitle: Text(_getTypeDescription(type)),
            value: type,
            groupValue: _selectedType,
            onChanged: (EventType? value) {
              setState(() {
                _selectedType = value!;
                // Auto-enable yearly repeat for birthdays and poya events
                if (type == EventType.birthday || type == EventType.poya) {
                  _repeatYearly = true;
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text('Event Time (Optional)'),
        subtitle: Text(
          _selectedTime != null
              ? _selectedTime!.format(context)
              : 'No specific time set',
          style: TextStyle(
            color: _selectedTime != null
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: _selectedTime != null
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        trailing: _selectedTime != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () => setState(() => _selectedTime = null),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _selectTime,
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Event Date'),
        subtitle: Text(
          DateFormat('EEEE, MMMM d, y').format(_selectedDate),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildOptionsSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Repeat Yearly'),
            subtitle: const Text('Event will repeat every year'),
            value: _repeatYearly,
            onChanged: (bool value) {
              setState(() {
                _repeatYearly = value;
              });
            },
            secondary: const Icon(Icons.repeat),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminded about this event'),
            value: _notificationEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications),
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
        return 'Custom';
    }
  }

  String _getTypeDescription(EventType type) {
    switch (type) {
      case EventType.birthday:
        return 'Celebrate special birthdays';
      case EventType.exam:
        return 'Important exams and tests';
      case EventType.poya:
        return 'Poya day observances';
      case EventType.custom:
        return 'Any other special occasion';
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Select Event Time',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Event Date',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final event = Event(
        id: _isEditing
            ? widget.eventToEdit!.id
            : _eventController.generateEventId(),
        title: _titleController.text.trim(),
        eventDate: _selectedDate,
        eventTime: _selectedTime,
        type: _selectedType,
        repeatYearly: _repeatYearly,
        notificationEnabled: _notificationEnabled,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
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
          _isEditing
              ? 'Event updated successfully!'
              : 'Event created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // If event creation failed, show option to create without notifications
        _showCreateWithoutNotificationsDialog();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${widget.eventToEdit!.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _eventController.deleteEvent(
          widget.eventToEdit!.id,
        );
        if (success) {
          Get.back(); // Go back to previous screen
          Get.snackbar(
            'Success',
            'Event deleted successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete event: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCreateWithoutNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Issue'),
        content: const Text(
          'There was an issue setting up notifications for this event. '
          'Would you like to create the event without notifications?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createEventWithoutNotifications();
            },
            child: const Text('Create Without Notifications'),
          ),
        ],
      ),
    );
  }

  Future<void> _createEventWithoutNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final event = Event(
        id: _isEditing
            ? widget.eventToEdit!.id
            : _eventController.generateEventId(),
        title: _titleController.text.trim(),
        eventDate: _selectedDate,
        eventTime: _selectedTime,
        type: _selectedType,
        repeatYearly: _repeatYearly,
        notificationEnabled: false, // Disable notifications
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
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
          '${_isEditing ? "Event updated" : "Event created"} successfully! (Notifications disabled)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
