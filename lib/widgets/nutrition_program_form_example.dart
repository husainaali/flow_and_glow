import 'package:flutter/material.dart';
import '../models/program_model.dart';
import '../utils/app_colors.dart';

/// Example widget showing how to create a nutrition program form
/// This should be integrated into your existing program creation dialog
class NutritionProgramFormExample extends StatefulWidget {
  const NutritionProgramFormExample({super.key});

  @override
  State<NutritionProgramFormExample> createState() => _NutritionProgramFormExampleState();
}

class _NutritionProgramFormExampleState extends State<NutritionProgramFormExample> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _trainerController = TextEditingController();
  final _priceController = TextEditingController();
  
  // Nutrition-specific fields
  int _mealsPerDay = 3;
  int _daysPerWeek = 5;
  int _subscriptionMonths = 3;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Nutrition Program',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Program Title',
              hintText: 'e.g., Healthy Meal Plan',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your meal plan...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          // Trainer/Nutritionist
          TextField(
            controller: _trainerController,
            decoration: const InputDecoration(
              labelText: 'Nutritionist Name',
              hintText: 'e.g., Dr. Sarah Ahmed',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Meals Per Day
          const Text(
            'Meals Per Day',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildNumberButton(1, _mealsPerDay == 1, () {
                setState(() => _mealsPerDay = 1);
              }),
              const SizedBox(width: 8),
              _buildNumberButton(2, _mealsPerDay == 2, () {
                setState(() => _mealsPerDay = 2);
              }),
              const SizedBox(width: 8),
              _buildNumberButton(3, _mealsPerDay == 3, () {
                setState(() => _mealsPerDay = 3);
              }),
            ],
          ),
          const SizedBox(height: 24),
          
          // Days Per Week
          const Text(
            'Days Per Week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildNumberButton(3, _daysPerWeek == 3, () {
                setState(() => _daysPerWeek = 3);
              }),
              const SizedBox(width: 8),
              _buildNumberButton(5, _daysPerWeek == 5, () {
                setState(() => _daysPerWeek = 5);
              }),
              const SizedBox(width: 8),
              _buildNumberButton(7, _daysPerWeek == 7, () {
                setState(() => _daysPerWeek = 7);
              }),
            ],
          ),
          const SizedBox(height: 24),
          
          // Subscription Duration
          const Text(
            'Base Subscription Duration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMonthChip(1),
              _buildMonthChip(2),
              _buildMonthChip(3),
              _buildMonthChip(6),
              _buildMonthChip(12),
            ],
          ),
          const SizedBox(height: 24),
          
          // Price
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Base Price (BHD)',
              hintText: 'Price for $_mealsPerDay meals/day × $_daysPerWeek days/week × $_subscriptionMonths months',
              border: const OutlineInputBorder(),
              prefixText: 'BHD ',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Price breakdown
          if (_priceController.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total meals: ${_calculateTotalMeals()} meals',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    'Price per meal: BHD ${_calculatePricePerMeal().toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          
          // Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createProgram,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Create Nutrition Program',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberButton(int number, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.textSecondary.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMonthChip(int months) {
    final isSelected = _subscriptionMonths == months;
    return ChoiceChip(
      label: Text(months == 1 ? '1 Month' : '$months Months'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _subscriptionMonths = months);
        }
      },
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
  
  int _calculateTotalMeals() {
    return _mealsPerDay * _daysPerWeek * _subscriptionMonths * 4; // 4 weeks per month
  }
  
  double _calculatePricePerMeal() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final totalMeals = _calculateTotalMeals();
    return totalMeals > 0 ? price / totalMeals : 0;
  }
  
  void _createProgram() {
    // Validate inputs
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _trainerController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    
    // Create the nutrition program
    final program = ProgramModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      centerId: 'your-center-id', // Get from context
      categoryId: 'nutrition-category-id',
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      trainer: _trainerController.text,
      createdAt: DateTime.now(),
      programType: ProgramType.nutrition,
      mealsPerDay: _mealsPerDay,
      daysPerWeek: _daysPerWeek,
      subscriptionMonths: _subscriptionMonths,
    );
    
    // Save to database
    // await firestoreService.createProgram(program);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nutrition program created successfully!')),
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _trainerController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
