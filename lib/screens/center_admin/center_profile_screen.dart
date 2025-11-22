import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../utils/app_colors.dart';
import '../../models/center_model.dart';
import '../../models/trainer_model.dart';
import '../../models/program_model.dart';
import '../../models/service_type_model.dart';
import '../../models/package_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../customer/program_detail_screen.dart';
import '../customer/package_detail_screen_new.dart';
import 'add_service_dialog.dart';

class CenterProfileScreen extends ConsumerStatefulWidget {
  const CenterProfileScreen({super.key});

  @override
  ConsumerState<CenterProfileScreen> createState() => _CenterProfileScreenState();
}

class _CenterProfileScreenState extends ConsumerState<CenterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  
  // Center Details Controllers
  final _centerNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Trainers
  List<TrainerModel> _trainers = [];
  
  // Service Types (Yoga, Pilates, etc.)
  List<ServiceTypeModel> _serviceTypes = [];
  
  // Programs
  List<ProgramModel> _programs = [];
  
  // Packages
  List<PackageModel> _packages = [];
  
  CenterModel? _currentCenter;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _centerImageUrl;

  @override
  void initState() {
    super.initState();
    _loadCenterData();
  }

  Future<void> _loadCenterData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      CenterModel? center;
      
      // First try to get center by centerId if available
      if (user.centerId != null && user.centerId!.isNotEmpty) {
        center = await _firestoreService.getCenter(user.centerId!);
      }
      
      // If no center found by centerId, try to find by adminId
      if (center == null) {
        center = await _firestoreService.getCenterByAdminId(user.uid);
      }
      
      if (center != null && mounted) {
        setState(() {
          _currentCenter = center;
          _centerNameController.text = center!.name;
          _titleController.text = center.title ?? '';
          _descriptionController.text = center.description;
          _addressController.text = center.address;
          _centerImageUrl = center.imageUrl;
          _trainers = List.from(center.trainers);
          _serviceTypes = List.from(center.serviceTypes);
          _programs = List.from(center.programs);
        });
      }
    } catch (e) {
      print('Error loading center data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading center data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveCenter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider).value;
      
      if (_currentCenter == null) {
        // Create new center
        final newCenter = CenterModel(
          id: '',
          name: _centerNameController.text.trim(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          imageUrl: _centerImageUrl ?? '',
          status: CenterStatus.pending,
          adminId: user!.uid,
          createdAt: DateTime.now(),
          trainers: _trainers,
          serviceTypes: _serviceTypes,
          programs: _programs,
        );
        final centerId = await _firestoreService.createCenter(newCenter);
        
        // Update user's centerId
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'centerId': centerId});
      } else {
        // Update existing center
        await _firestoreService.updateCenter(
          _currentCenter!.id,
          {
            'name': _centerNameController.text.trim(),
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'address': _addressController.text.trim(),
            'imageUrl': _centerImageUrl ?? '',
            'trainers': _trainers.map((t) => t.toMap()).toList(),
            'serviceTypes': _serviceTypes.map((s) => s.toMap()).toList(),
            'programs': _programs.map((p) => p.toMap()).toList(),
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Center saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving center: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickHeaderImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      // Upload to Firebase Storage
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading header image...'),
              ],
            ),
          ),
        );
        
        final storageService = StorageService();
        final centerId = _currentCenter?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        final imageUrl = await storageService.uploadCenterImage(
          File(pickedFile.path),
          centerId,
        );
        
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          setState(() {
            _centerImageUrl = imageUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Header image uploaded successfully!')),
          );
        }
      } catch (e) {
        print('Error uploading header image: $e');
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          // Fallback to local path if upload fails
          setState(() {
            _centerImageUrl = pickedFile.path;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Using local image: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveCenter,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _buildSectionTitle('Center Details'),
              const SizedBox(height: 16),
              
              // Header Photo
              _buildHeaderPhotoSection(),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _centerNameController,
                label: 'Center Name',
                hint: 'e.g., Flow and Grow Wellness',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: 'Title / Tagline',
                hint: 'Your Sanctuary for Mind & Body',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Discover your inner strength and tranquility...',
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'e.g., Building 123, Road 456, Manama',
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              
              // Manage Trainers Section
              _buildSectionTitle('Manage Trainers'),
              const SizedBox(height: 16),
              ..._trainers.asMap().entries.map((entry) {
                return _buildTrainerCard(entry.key, entry.value);
              }),
              _buildAddButton('Add Trainer', _showAddTrainerDialog),
              const SizedBox(height: 32),
              
              // Manage Service Types Section
              _buildSectionTitle('Manage Services'),
              const Text(
                'Add service types offered at your center (e.g., Yoga, Pilates, Nutrition, Therapy)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ..._serviceTypes.asMap().entries.map((entry) {
                return _buildServiceTypeCard(entry.key, entry.value);
              }),
              _buildAddButton('Add Service Type', _showAddServiceTypeDialog),
              const SizedBox(height: 32),
              
              // Manage Programs Section
              _buildSectionTitle('Manage Programs'),
              const Text(
                'Add scheduled programs with trainer, dates, and pricing',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ..._programs.asMap().entries.map((entry) {
                return _buildProgramCard(entry.key, entry.value);
              }),
              _buildAddButton('Add Program', _showAddProgramDialog),
              const SizedBox(height: 32),
              
              // Manage Packages Section
              _buildSectionTitle('Manage Packages'),
              const SizedBox(height: 16),
              ..._packages.asMap().entries.map((entry) {
                return _buildPackageCard(entry.key, entry.value);
              }),
              _buildAddButton('Add Package', _showAddPackageDialog),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHeaderPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Header Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickHeaderImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _centerImageUrl != null && _centerImageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _centerImageUrl!.startsWith('http')
                        ? Image.network(
                            _centerImageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_centerImageUrl!),
                            fit: BoxFit.cover,
                          ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add header photo',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTrainerCard(int index, TrainerModel trainer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary,
          backgroundImage: trainer.imageUrl.isNotEmpty
              ? (trainer.imageUrl.startsWith('http')
                  ? NetworkImage(trainer.imageUrl)
                  : FileImage(File(trainer.imageUrl)) as ImageProvider)
              : null,
          child: trainer.imageUrl.isEmpty
              ? const Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
        title: Text(
          trainer.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(trainer.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.accent),
              onPressed: () => _showEditTrainerDialog(index, trainer),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTrainer(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeCard(int index, ServiceTypeModel serviceType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.fitness_center,
          color: AppColors.primary,
          size: 32,
        ),
        title: Text(
          serviceType.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(serviceType.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.accent),
              onPressed: () => _showEditServiceTypeDialog(index, serviceType),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteServiceType(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(int index, ProgramModel program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProgramDetailScreen(program: program),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Program Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: program.headerImageUrl != null && program.headerImageUrl!.isNotEmpty
                    ? (program.headerImageUrl!.startsWith('http')
                        ? Image.network(
                            program.headerImageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: AppColors.secondary,
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Image.file(
                            File(program.headerImageUrl!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: AppColors.secondary,
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              );
                            },
                          ))
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppColors.secondary,
                        child: const Icon(
                          Icons.fitness_center,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Program Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${program.trainer} • ${program.formattedPricing}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (program.weeklyDays.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${program.formattedSchedule} • ${program.startTime}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.accent),
                    onPressed: () => _showEditProgramDialog(index, program),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProgram(index),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPackageCard(int index, PackageModel package) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to package detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PackageDetailScreenNew(package: package),
            ),
          );
        },
        child: ListTile(
          leading: package.headerImageUrl != null && package.headerImageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    package.headerImageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: AppColors.secondary,
                        child: const Icon(Icons.card_giftcard, color: AppColors.primary),
                      );
                    },
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.card_giftcard, color: AppColors.primary),
                ),
          title: Text(
            package.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${package.programIds.length} programs • BHD ${package.price}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.accent),
                onPressed: () => _showEditPackageDialog(index, package),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePackage(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(String label, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, color: AppColors.accent),
      label: Text(
        label,
        style: const TextStyle(color: AppColors.accent),
      ),
    );
  }

  // Helper method to upload trainer image
  Future<void> _uploadTrainerImage(String name, String title, File imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading image...'),
          ],
        ),
      ),
    );
    
    try {
      final storageService = StorageService();
      final trainerId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrl = await storageService.uploadTrainerImage(
        imageFile,
        trainerId,
      );
      
      if (mounted) {
        setState(() {
          _trainers.add(TrainerModel(
            id: trainerId,
            name: name,
            title: title,
            imageUrl: imageUrl,
          ));
        });
        
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trainer added successfully!')),
        );
      }
    } catch (e) {
      print('Error uploading trainer image: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Helper method to update trainer image
  Future<void> _updateTrainerImage(int index, TrainerModel trainer, String name, String title, File imageFile, String oldImageUrl) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading image...'),
          ],
        ),
      ),
    );
    
    try {
      final storageService = StorageService();
      final newImageUrl = await storageService.uploadTrainerImage(
        imageFile,
        trainer.id,
      );
      
      // Delete old image if exists
      if (oldImageUrl.isNotEmpty && oldImageUrl.startsWith('http')) {
        await storageService.deleteImage(oldImageUrl);
      }
      
      if (mounted) {
        setState(() {
          _trainers[index] = TrainerModel(
            id: trainer.id,
            name: name,
            title: title,
            imageUrl: newImageUrl,
          );
        });
        
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trainer updated successfully!')),
        );
      }
    } catch (e) {
      print('Error uploading trainer image: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Trainer Dialogs
  void _showAddTrainerDialog() {
    final nameController = TextEditingController();
    final titleController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Trainer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview
                if (selectedImage != null)
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                      image: DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (pickedFile != null) {
                      setDialogState(() {
                        selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text(selectedImage == null ? 'Select Image' : 'Change Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && titleController.text.isNotEmpty) {
                  final name = nameController.text;
                  final title = titleController.text;
                  final imageToUpload = selectedImage;
                  
                  // Close dialog
                  Navigator.of(context).pop();
                  
                  // Process upload after dialog is closed
                  if (imageToUpload != null) {
                    _uploadTrainerImage(name, title, imageToUpload);
                  } else {
                    // No image selected, add trainer without image
                    setState(() {
                      _trainers.add(TrainerModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        title: title,
                        imageUrl: '',
                      ));
                    });
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTrainerDialog(int index, TrainerModel trainer) {
    final nameController = TextEditingController(text: trainer.name);
    final titleController = TextEditingController(text: trainer.title);
    String imageUrl = trainer.imageUrl;
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit Trainer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview
                if (selectedImage != null)
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                      image: DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else if (imageUrl.isNotEmpty)
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (pickedFile != null) {
                      setDialogState(() {
                        selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Change Image'),
                ),
              ],
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && titleController.text.isNotEmpty) {
                final name = nameController.text;
                final title = titleController.text;
                final imageToUpload = selectedImage;
                final oldImageUrl = imageUrl;
                
                // Close dialog
                Navigator.of(context).pop();
                
                // Upload new image if selected
                if (imageToUpload != null) {
                  _updateTrainerImage(index, trainer, name, title, imageToUpload, oldImageUrl);
                } else {
                  // No new image, just update text fields
                  setState(() {
                    _trainers[index] = TrainerModel(
                      id: trainer.id,
                      name: name,
                      title: title,
                      imageUrl: oldImageUrl,
                    );
                  });
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
        ),
      ),
    );
  }

  void _deleteTrainer(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trainer'),
        content: const Text('Are you sure you want to delete this trainer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _trainers.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Service Type Dialogs
  void _showAddServiceTypeDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Service Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (pickedFile != null) {
                      setDialogState(() {
                        selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      image: selectedImage != null
                          ? DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Service Photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    hintText: 'e.g., Yoga, Pilates, Nutrition',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description of the service',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  String? iconName;
                  
                  // Upload image if selected
                  if (selectedImage != null) {
                    try {
                      final storageService = StorageService();
                      final serviceTypeId = DateTime.now().millisecondsSinceEpoch.toString();
                      iconName = await storageService.uploadCenterImage(
                        selectedImage!,
                        'service_types/$serviceTypeId',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error uploading image: $e')),
                        );
                      }
                    }
                  }
                  
                  setState(() {
                    _serviceTypes.add(ServiceTypeModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      description: descriptionController.text,
                      iconName: iconName,
                      createdAt: DateTime.now(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditServiceTypeDialog(int index, ServiceTypeModel serviceType) {
    final nameController = TextEditingController(text: serviceType.name);
    final descriptionController = TextEditingController(text: serviceType.description);
    File? selectedImage;
    String? existingIconName = serviceType.iconName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Service Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (pickedFile != null) {
                      setDialogState(() {
                        selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      image: selectedImage != null
                          ? DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : (existingIconName != null && existingIconName.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(existingIconName),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child: selectedImage == null && (existingIconName == null || existingIconName.isEmpty)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Service Photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  String? iconName = existingIconName;
                  
                  // Upload new image if selected
                  if (selectedImage != null) {
                    try {
                      final storageService = StorageService();
                      iconName = await storageService.uploadCenterImage(
                        selectedImage!,
                        'service_types/${serviceType.id}',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error uploading image: $e')),
                        );
                      }
                    }
                  }
                  
                  setState(() {
                    _serviceTypes[index] = ServiceTypeModel(
                      id: serviceType.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      iconName: iconName,
                      createdAt: serviceType.createdAt,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteServiceType(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Type'),
        content: const Text('Are you sure you want to delete this service type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _serviceTypes.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Program Dialogs
  Future<void> _showAddProgramDialog() async {
    final user = ref.read(currentUserProvider).value;
    final result = await showDialog<ProgramModel>(
      context: context,
      builder: (context) => AddServiceDialog(
        trainers: _trainers,
        centerId: user?.centerId ?? _currentCenter?.id ?? '',
      ),
    );
    
    if (result != null) {
      setState(() {
        _programs.add(result);
      });
    }
  }

  Future<void> _showEditProgramDialog(int index, ProgramModel program) async {
    final result = await showDialog<ProgramModel>(
      context: context,
      builder: (context) => AddServiceDialog(
        existingService: program,
        trainers: _trainers,
        centerId: program.centerId,
      ),
    );
    
    if (result != null) {
      setState(() {
        _programs[index] = result;
      });
    }
  }

  void _deleteProgram(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program'),
        content: const Text('Are you sure you want to delete this program?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _programs.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  // Package Dialogs
  void _showAddPackageDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    Set<String> selectedProgramIds = {};
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Package'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Image
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1200,
                        maxHeight: 800,
                        imageQuality: 85,
                      );
                      if (pickedFile != null) {
                        setDialogState(() {
                          selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Package Photo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Package Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Package Price (BHD)',
                      prefixText: 'BHD ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Programs to Include:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_programs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No programs available. Please add programs first.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ..._programs.map((program) {
                      final isSelected = selectedProgramIds.contains(program.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedProgramIds.add(program.id);
                            } else {
                              selectedProgramIds.remove(program.id);
                            }
                          });
                        },
                        title: Text(program.title),
                        subtitle: Text('${program.trainer} • BHD ${program.price}'),
                        secondary: program.headerImageUrl != null && program.headerImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  program.headerImageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: AppColors.secondary,
                                      child: const Icon(Icons.fitness_center, size: 24),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.fitness_center, size: 24),
                              ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && selectedProgramIds.isNotEmpty) {
                  String? imageUrl;
                  
                  // Upload image if selected
                  if (selectedImage != null) {
                    try {
                      final storageService = StorageService();
                      final packageId = DateTime.now().millisecondsSinceEpoch.toString();
                      imageUrl = await storageService.uploadCenterImage(
                        selectedImage!,
                        'packages/$packageId',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error uploading image: $e')),
                        );
                      }
                    }
                  }
                  
                  setState(() {
                    _packages.add(PackageModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      centerId: _currentCenter?.id ?? '',
                      centerName: _centerNameController.text,
                      title: titleController.text,
                      description: descriptionController.text,
                      programIds: selectedProgramIds.toList(),
                      headerImageUrl: imageUrl,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      createdAt: DateTime.now(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPackageDialog(int index, PackageModel package) {
    final titleController = TextEditingController(text: package.title);
    final descriptionController = TextEditingController(text: package.description);
    final priceController = TextEditingController(text: package.price.toString());
    Set<String> selectedProgramIds = Set.from(package.programIds);
    File? selectedImage;
    String? existingImageUrl = package.headerImageUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Package'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Image
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1200,
                        maxHeight: 800,
                        imageQuality: 85,
                      );
                      if (pickedFile != null) {
                        setDialogState(() {
                          selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : (existingImageUrl != null && existingImageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(existingImageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: selectedImage == null && (existingImageUrl == null || existingImageUrl.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Package Photo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Package Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Package Price (BHD)',
                      prefixText: 'BHD ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Programs to Include:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_programs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No programs available.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ..._programs.map((program) {
                      final isSelected = selectedProgramIds.contains(program.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedProgramIds.add(program.id);
                            } else {
                              selectedProgramIds.remove(program.id);
                            }
                          });
                        },
                        title: Text(program.title),
                        subtitle: Text('${program.trainer} • BHD ${program.price}'),
                        secondary: program.headerImageUrl != null && program.headerImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  program.headerImageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: AppColors.secondary,
                                      child: const Icon(Icons.fitness_center, size: 24),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.fitness_center, size: 24),
                              ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && selectedProgramIds.isNotEmpty) {
                  String? imageUrl = existingImageUrl;
                  
                  // Upload new image if selected
                  if (selectedImage != null) {
                    try {
                      final storageService = StorageService();
                      imageUrl = await storageService.uploadCenterImage(
                        selectedImage!,
                        'packages/${package.id}',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error uploading image: $e')),
                        );
                      }
                    }
                  }
                  
                  setState(() {
                    _packages[index] = package.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      programIds: selectedProgramIds.toList(),
                      headerImageUrl: imageUrl,
                      price: double.tryParse(priceController.text) ?? package.price,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePackage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: const Text('Are you sure you want to delete this package?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _packages.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _centerNameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
