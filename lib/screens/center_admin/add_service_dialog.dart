import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/service_model.dart';
import '../../models/trainer_model.dart';
import '../../models/category_model.dart';
import '../../providers/firestore_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';

class AddServiceDialog extends ConsumerStatefulWidget {
  final ServiceModel? existingService;
  final List<TrainerModel> trainers;
  final String centerId;

  const AddServiceDialog({
    super.key,
    this.existingService,
    required this.trainers,
    required this.centerId,
  });

  @override
  ConsumerState<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends ConsumerState<AddServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '1');
  
  ServiceType _serviceType = ServiceType.program;
  String? _selectedTrainer;
  String? _selectedCategoryId;
  Set<DayOfWeek> _selectedDays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  int _durationMinutes = 60;
  DateTime? _programStartDate;
  DateTime? _programEndDate;
  PricingPeriod _pricingPeriod = PricingPeriod.month;
  int _pricingDuration = 1;
  File? _headerImage;
  String? _existingHeaderImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingService != null) {
      _initializeFromExisting();
    }
  }

  void _initializeFromExisting() {
    final service = widget.existingService!;
    _titleController.text = service.title;
    _descriptionController.text = service.description;
    _priceController.text = service.price.toString();
    _serviceType = service.serviceType;
    _selectedTrainer = service.trainer;
    _selectedCategoryId = service.categoryId;
    _selectedDays = service.weeklyDays.toSet();
    _durationMinutes = service.durationMinutes;
    _programStartDate = service.programStartDate;
    _programEndDate = service.programEndDate;
    _pricingPeriod = service.pricingPeriod;
    _pricingDuration = service.pricingDuration;
    _existingHeaderImageUrl = service.headerImageUrl;
    _durationController.text = _pricingDuration.toString();
    
    if (service.startTime.isNotEmpty) {
      final parts = service.startTime.split(':');
      _startTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickHeaderImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _headerImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadHeaderImage() async {
    if (_headerImage == null) return _existingHeaderImageUrl;
    
    try {
      final storageService = StorageService();
      final imageUrl = await storageService.uploadCenterImage(_headerImage!, widget.centerId);
      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
      return null;
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _calculateEndDate() {
    if (_programStartDate == null) return;
    
    DateTime endDate = _programStartDate!;
    switch (_pricingPeriod) {
      case PricingPeriod.week:
        endDate = _programStartDate!.add(Duration(days: 7 * _pricingDuration));
        break;
      case PricingPeriod.month:
        endDate = DateTime(
          _programStartDate!.year,
          _programStartDate!.month + _pricingDuration,
          _programStartDate!.day,
        );
        break;
      case PricingPeriod.year:
        endDate = DateTime(
          _programStartDate!.year + _pricingDuration,
          _programStartDate!.month,
          _programStartDate!.day,
        );
        break;
    }
    
    setState(() {
      _programEndDate = endDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: AppColors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.existingService == null ? 'Add Service' : 'Edit Service',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Type Selection
                      _buildSectionTitle('Service Type'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeChip(
                              'Program',
                              ServiceType.program,
                              Icons.fitness_center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeChip(
                              'Nutrition',
                              ServiceType.nutrition,
                              Icons.restaurant_menu,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Header Image
                      _buildSectionTitle('Header Photo'),
                      const SizedBox(height: 8),
                      _buildHeaderImageSection(),
                      const SizedBox(height: 24),
                      
                      // Basic Info
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      
                      // Category Selection
                      _buildSectionTitle('Category *'),
                      const SizedBox(height: 8),
                      categoriesAsync.when(
                        data: (categories) => _buildCategoryChips(categories),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading categories'),
                      ),
                      const SizedBox(height: 24),
                      
                      // Trainer Selection
                      _buildSectionTitle('Trainer *'),
                      const SizedBox(height: 8),
                      _buildTrainerChips(),
                      const SizedBox(height: 24),
                      
                      if (_serviceType == ServiceType.program) ...[
                        // Weekly Schedule
                        _buildSectionTitle('Weekly Schedule *'),
                        const SizedBox(height: 8),
                        _buildDaySelector(),
                        const SizedBox(height: 24),
                        
                        // Time & Duration
                        _buildSectionTitle('Time & Duration'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeSelector(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDurationSelector(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'End Time: ${_calculateEndTime()}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Program Dates
                        _buildSectionTitle('Program Period *'),
                        const SizedBox(height: 12),
                        _buildDateSelector(),
                        const SizedBox(height: 24),
                      ],
                      
                      // Pricing
                      _buildSectionTitle('Pricing'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Price (BHD) *',
                                border: OutlineInputBorder(),
                                prefixText: 'BHD ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _pricingDuration = int.tryParse(value) ?? 1;
                                  _calculateEndDate();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<PricingPeriod>(
                              value: _pricingPeriod,
                              decoration: const InputDecoration(
                                labelText: 'Period',
                                border: OutlineInputBorder(),
                              ),
                              items: PricingPeriod.values.map((period) {
                                return DropdownMenuItem(
                                  value: period,
                                  child: Text(period.toString().split('.').last),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _pricingPeriod = value!;
                                  _calculateEndDate();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _handleSave,
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.existingService == null ? 'Add' : 'Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTypeChip(String label, ServiceType type, IconData icon) {
    final isSelected = _serviceType == type;
    return InkWell(
      onTap: () => setState(() => _serviceType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.primary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImageSection() {
    return InkWell(
      onTap: _pickHeaderImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          image: _headerImage != null
              ? DecorationImage(
                  image: FileImage(_headerImage!),
                  fit: BoxFit.cover,
                )
              : (_existingHeaderImageUrl != null && _existingHeaderImageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_existingHeaderImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null),
        ),
        child: _headerImage == null && (_existingHeaderImageUrl == null || _existingHeaderImageUrl!.isEmpty)
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text(
                      'Add Header Photo',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryChips(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return const Text(
        'No categories available',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = _selectedCategoryId == category.id;
        return ActionChip(
          label: Text(category.name),
          avatar: category.iconUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(category.iconUrl),
                )
              : null,
          backgroundColor: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.secondary,
          side: BorderSide(
            color: isSelected ? AppColors.accent : AppColors.primary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          onPressed: () => setState(() => _selectedCategoryId = category.id),
        );
      }).toList(),
    );
  }

  Widget _buildTrainerChips() {
    if (widget.trainers.isEmpty) {
      return const Text(
        'No trainers added yet',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.trainers.map((trainer) {
        final isSelected = _selectedTrainer == trainer.name;
        return ActionChip(
          label: Text(trainer.name),
          avatar: CircleAvatar(
            backgroundColor: isSelected ? AppColors.accent : AppColors.secondary,
            backgroundImage: trainer.imageUrl.isNotEmpty
                ? (trainer.imageUrl.startsWith('http')
                    ? NetworkImage(trainer.imageUrl)
                    : FileImage(File(trainer.imageUrl)) as ImageProvider)
                : null,
            child: trainer.imageUrl.isEmpty
                ? Icon(
                    Icons.person,
                    size: 16,
                    color: isSelected ? AppColors.white : AppColors.primary,
                  )
                : null,
          ),
          backgroundColor: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.secondary,
          side: BorderSide(
            color: isSelected ? AppColors.accent : AppColors.primary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          onPressed: () => setState(() => _selectedTrainer = trainer.name),
        );
      }).toList(),
    );
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DayOfWeek.values.map((day) {
        final isSelected = _selectedDays.contains(day);
        String dayName;
        switch (day) {
          case DayOfWeek.sunday:
            dayName = 'Sun';
            break;
          case DayOfWeek.monday:
            dayName = 'Mon';
            break;
          case DayOfWeek.tuesday:
            dayName = 'Tue';
            break;
          case DayOfWeek.wednesday:
            dayName = 'Wed';
            break;
          case DayOfWeek.thursday:
            dayName = 'Thu';
            break;
          case DayOfWeek.friday:
            dayName = 'Fri';
            break;
          case DayOfWeek.saturday:
            dayName = 'Sat';
            break;
        }
        
        return FilterChip(
          label: Text(dayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(day);
              } else {
                _selectedDays.remove(day);
              }
            });
          },
          selectedColor: AppColors.accent.withOpacity(0.2),
          checkmarkColor: AppColors.accent,
        );
      }).toList(),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _startTime,
        );
        if (time != null) {
          setState(() => _startTime = time);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Start Time',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time),
        ),
        child: Text(_startTime.format(context)),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return DropdownButtonFormField<int>(
      value: _durationMinutes,
      decoration: const InputDecoration(
        labelText: 'Duration',
        border: OutlineInputBorder(),
      ),
      items: [30, 45, 60, 90, 120, 150, 180].map((minutes) {
        final hours = minutes ~/ 60;
        final mins = minutes % 60;
        String label;
        if (hours > 0 && mins > 0) {
          label = '${hours}h ${mins}m';
        } else if (hours > 0) {
          label = '${hours}h';
        } else {
          label = '${mins}m';
        }
        return DropdownMenuItem(
          value: minutes,
          child: Text(label),
        );
      }).toList(),
      onChanged: (value) => setState(() => _durationMinutes = value!),
    );
  }

  String _calculateEndTime() {
    final totalMinutes = _startTime.hour * 60 + _startTime.minute + _durationMinutes;
    final endHour = (totalMinutes ~/ 60) % 24;
    final endMinute = totalMinutes % 60;
    final endTime = TimeOfDay(hour: endHour, minute: endMinute);
    return endTime.format(context);
  }

  Widget _buildDateSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _programStartDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (date != null) {
                    setState(() {
                      _programStartDate = date;
                      _calculateEndDate();
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _programStartDate != null
                        ? '${_getMonthName(_programStartDate!.month)} ${_programStartDate!.day}, ${_programStartDate!.year}'
                        : 'Select date',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _programEndDate != null
                      ? '${_getMonthName(_programEndDate!.month)} ${_programEndDate!.day}, ${_programEndDate!.year}'
                      : 'Auto-calculated',
                  style: TextStyle(
                    color: _programEndDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    
    if (_selectedTrainer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trainer')),
      );
      return;
    }
    
    if (_serviceType == ServiceType.program) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
        return;
      }
      
      if (_programStartDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date')),
        );
        return;
      }
    }

    setState(() => _isUploading = true);
    
    final headerImageUrl = await _uploadHeaderImage();
    
    final service = ServiceModel(
      id: widget.existingService?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      centerId: widget.centerId,
      categoryId: _selectedCategoryId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      trainer: _selectedTrainer!,
      createdAt: widget.existingService?.createdAt ?? DateTime.now(),
      serviceType: _serviceType,
      weeklyDays: _selectedDays.toList()..sort((a, b) => a.index.compareTo(b.index)),
      startTime: _formatTime(_startTime),
      durationMinutes: _durationMinutes,
      programStartDate: _programStartDate,
      programEndDate: _programEndDate,
      pricingPeriod: _pricingPeriod,
      pricingDuration: _pricingDuration,
      headerImageUrl: headerImageUrl,
    );

    if (mounted) {
      Navigator.pop(context, service);
    }
  }
}
