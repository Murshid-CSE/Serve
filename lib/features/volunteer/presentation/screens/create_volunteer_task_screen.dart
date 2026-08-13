import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/volunteer/presentation/providers/volunteer_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/app_text_field.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:intl/intl.dart';

class CreateVolunteerTaskScreen extends ConsumerStatefulWidget {
  const CreateVolunteerTaskScreen({super.key});

  @override
  ConsumerState<CreateVolunteerTaskScreen> createState() => _CreateVolunteerTaskScreenState();
}

class _CreateVolunteerTaskScreenState extends ConsumerState<CreateVolunteerTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _volunteersNeededController = TextEditingController(text: '5');

  String _selectedType = 'distribution';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  static const _taskTypes = [
    {'value': 'distribution', 'label': 'Food Distribution', 'icon': Icons.fastfood_rounded},
    {'value': 'rescue', 'label': 'Rescue Operation', 'icon': Icons.health_and_safety_rounded},
    {'value': 'event', 'label': 'Community Event', 'icon': Icons.event_rounded},
    {'value': 'cleanup', 'label': 'Cleanup Drive', 'icon': Icons.cleaning_services_rounded},
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await GeoUtils.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        final address = await GeoUtils.getAddressFromCoordinates(
          position.latitude, position.longitude,
        );
        if (mounted && address.isNotEmpty) {
          _addressController.text = address;
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _volunteersNeededController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      context.showErrorSnackBar('Please wait for location to be fetched.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('User not signed in');

      final taskDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await ref.read(volunteerActionsProvider).createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        address: _addressController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        date: taskDate,
        volunteersNeeded: int.tryParse(_volunteersNeededController.text) ?? 5,
        creatorId: user.uid,
        creatorName: user.name,
      );

      if (!mounted) return;
      context.showSuccessSnackBar('Volunteer task created!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Failed to create task: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Type
              Text(
                'Task Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _taskTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type['icon'] as IconData, size: 18,
                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(type['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.tertiary,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type['value'] as String);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Title
              AppTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'e.g., Weekend Food Distribution Drive',
                prefixIcon: Icons.title_rounded,
                validator: Validators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What will volunteers be doing?',
                prefixIcon: Icons.description_rounded,
                maxLines: 4,
                validator: Validators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.tertiary),
                            const SizedBox(width: 10),
                            Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 20, color: AppColors.tertiary),
                            const SizedBox(width: 10),
                            Text(_selectedTime.format(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Volunteers Needed
              AppTextField(
                controller: _volunteersNeededController,
                label: 'Volunteers Needed',
                hint: 'How many volunteers?',
                prefixIcon: Icons.people_rounded,
                keyboardType: TextInputType.number,
                validator: Validators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Address
              AppTextField(
                controller: _addressController,
                label: 'Location / Address',
                hint: 'Where should volunteers meet?',
                prefixIcon: Icons.location_on_rounded,
                validator: Validators.required,
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),

              // Location status
              if (_latitude != null && _longitude != null)
                const Row(
                  children: [
                    Icon(Icons.gps_fixed_rounded, size: 14, color: AppColors.success),
                    SizedBox(width: 6),
                    Text('GPS captured', style: TextStyle(fontSize: 12, color: AppColors.success)),
                  ],
                ),
              const SizedBox(height: 32),

              // Submit
              AppButton(
                label: _isLoading ? 'Creating...' : 'Create Volunteer Task',
                onPressed: _isLoading ? null : _submitTask,
                isLoading: _isLoading,
                icon: Icons.volunteer_activism_rounded,
                color: AppColors.tertiary,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
