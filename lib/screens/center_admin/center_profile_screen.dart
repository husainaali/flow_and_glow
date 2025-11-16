import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/app_colors.dart';
import '../../models/center_model.dart';
import '../../models/trainer_model.dart';
import '../../models/service_model.dart';
import '../../models/package_model.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

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
  
  // Trainers
  List<TrainerModel> _trainers = [];
  
  // Services
  List<ServiceModel> _services = [];
  
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
      if (user?.centerId != null) {
        final center = await _firestoreService.getCenter(user!.centerId!);
        if (center != null) {
          setState(() {
            _currentCenter = center;
            _centerNameController.text = center.name;
            _titleController.text = center.title ?? '';
            _descriptionController.text = center.description;
            _centerImageUrl = center.imageUrl;
            _trainers = List.from(center.trainers);
            _services = List.from(center.services);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading center data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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
          address: '',
          imageUrl: _centerImageUrl ?? '',
          status: CenterStatus.pending,
          adminId: user!.uid,
          createdAt: DateTime.now(),
          trainers: _trainers,
          services: _services,
        );
        await _firestoreService.createCenter(newCenter);
      } else {
        // Update existing center
        await _firestoreService.updateCenter(
          _currentCenter!.id,
          {
            'name': _centerNameController.text.trim(),
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'imageUrl': _centerImageUrl ?? '',
            'trainers': _trainers.map((t) => t.toMap()).toList(),
            'services': _services.map((s) => s.toMap()).toList(),
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // TODO: Upload to Firebase Storage
      // For now, just store the local path
      setState(() {
        _centerImageUrl = pickedFile.path;
      });
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
              const SizedBox(height: 32),
              
              // Manage Trainers Section
              _buildSectionTitle('Manage Trainers'),
              const SizedBox(height: 16),
              ..._trainers.asMap().entries.map((entry) {
                return _buildTrainerCard(entry.key, entry.value);
              }),
              _buildAddButton('Add Trainer', _showAddTrainerDialog),
              const SizedBox(height: 32),
              
              // Manage Services Section
              _buildSectionTitle('Manage Services'),
              const SizedBox(height: 16),
              ..._services.asMap().entries.map((entry) {
                return _buildServiceCard(entry.key, entry.value);
              }),
              _buildAddButton('Add Service', _showAddServiceDialog),
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

  Widget _buildServiceCard(int index, ServiceModel service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          service.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${service.trainer} • BHD ${service.price}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.accent),
              onPressed: () => _showEditServiceDialog(index, service),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteService(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(int index, PackageModel package) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          package.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${package.instructor} • BHD ${package.price}'),
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

  // Service Dialogs
  void _showAddServiceDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedTrainer;
    String? selectedCategoryId;
    final categoriesAsync = ref.read(categoriesProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (BHD)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No categories available. Contact super admin.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = selectedCategoryId == category.id;
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
                          onPressed: () {
                            setDialogState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading categories'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Trainer',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (_trainers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No trainers added yet. Please add trainers first.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _trainers.map((trainer) {
                      final isSelected = selectedTrainer == trainer.name;
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
                        onPressed: () {
                          setDialogState(() {
                            selectedTrainer = trainer.name;
                          });
                        },
                      );
                    }).toList(),
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
              onPressed: () {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }
                if (selectedTrainer == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a trainer')),
                  );
                  return;
                }
                
                final user = ref.read(currentUserProvider).value;
                setState(() {
                  _services.add(ServiceModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    centerId: user?.centerId ?? '',
                    categoryId: selectedCategoryId!,
                    title: titleController.text,
                    description: descriptionController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    trainer: selectedTrainer!,
                    createdAt: DateTime.now(),
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditServiceDialog(int index, ServiceModel service) {
    final titleController = TextEditingController(text: service.title);
    final descriptionController = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.price.toString());
    String? selectedTrainer = service.trainer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (BHD)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Trainer',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (_trainers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No trainers added yet. Please add trainers first.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _trainers.map((trainer) {
                      final isSelected = selectedTrainer == trainer.name;
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
                        onPressed: () {
                          setDialogState(() {
                            selectedTrainer = trainer.name;
                          });
                        },
                      );
                    }).toList(),
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
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedTrainer != null) {
                  setState(() {
                    _services[index] = ServiceModel(
                      id: service.id,
                      centerId: service.centerId,
                      categoryId: service.categoryId,
                      title: titleController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      trainer: selectedTrainer!,
                      createdAt: service.createdAt,
                    );
                  });
                  Navigator.pop(context);
                } else if (selectedTrainer == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a trainer')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteService(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _services.removeAt(index);
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
    final instructorController = TextEditingController();
    final sessionsController = TextEditingController();
    PackageCategory selectedCategory = PackageCategory.yoga;
    PackageDuration selectedDuration = PackageDuration.monthly;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Package'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Package Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: instructorController,
                  decoration: const InputDecoration(labelText: 'Instructor'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PackageCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: PackageCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PackageDuration>(
                  value: selectedDuration,
                  decoration: const InputDecoration(labelText: 'Duration'),
                  items: PackageDuration.values.map((dur) {
                    return DropdownMenuItem(
                      value: dur,
                      child: Text(dur.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedDuration = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (BHD)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sessionsController,
                  decoration: const InputDecoration(labelText: 'Sessions per Week'),
                  keyboardType: TextInputType.number,
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
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _packages.add(PackageModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      centerId: _currentCenter?.id ?? '',
                      centerName: _centerNameController.text,
                      title: titleController.text,
                      description: descriptionController.text,
                      instructor: instructorController.text,
                      category: selectedCategory,
                      duration: selectedDuration,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      sessionsPerWeek: int.tryParse(sessionsController.text) ?? 0,
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

  void _showEditPackageDialog(int index, PackageModel package) {
    // Similar to add but with pre-filled values
    // Implementation similar to _showAddPackageDialog
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
    super.dispose();
  }
}
