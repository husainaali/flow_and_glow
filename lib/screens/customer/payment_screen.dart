import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  final String programTitle;
  final double price;
  final String currency;
  final Map<String, dynamic>? subscriptionDetails; // For nutrition programs

  const PaymentScreen({
    super.key,
    required this.programTitle,
    required this.price,
    this.currency = 'BD',
    this.subscriptionDetails,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'visa_1234',
      type: 'Visa',
      lastFour: '1234',
      expiryDate: '08/28',
    ),
  ];

  double get _taxAmount => widget.price * 0.10; // 10% tax
  double get _totalAmount => widget.price + _taxAmount;

  @override
  void initState() {
    super.initState();
    if (_paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = _paymentMethods.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6DC), // Light beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Color(0xFF8B6F5C), // Brown color from design
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B6F5C),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      widget.programTitle,
                      '${widget.currency} ${widget.price.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Taxes & Fees',
                      '${widget.currency} ${_taxAmount.toStringAsFixed(0)}',
                      isSubtext: true,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Total',
                      '${widget.currency} ${_totalAmount.toStringAsFixed(0)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Payment Method
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B6F5C),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Cards
              ..._paymentMethods.map((method) => _buildPaymentCard(method)),
              const SizedBox(height: 12),

              // Add New Card Button
              InkWell(
                onTap: _handleAddNewCard,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF8B6F5C),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E6DC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          color: Color(0xFF8B6F5C),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Add New Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8B6F5C),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF8B6F5C),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Secure SSL Encryption
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: const Color(0xFF8B6F5C).withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Secure SSL Encryption',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF8B6F5C).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Confirm Payment Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleConfirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE89B8D), // Coral color from design
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isSubtext = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : (isSubtext ? FontWeight.normal : FontWeight.w500),
            color: isSubtext ? const Color(0xFF8B6F5C).withOpacity(0.7) : const Color(0xFF8B6F5C),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF8B6F5C),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = method.id),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFE89B8D) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Visa Logo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F71),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${method.type} *****${method.lastFour}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B6F5C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expires ${method.expiryDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF8B6F5C).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE89B8D),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddNewCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new card functionality - Coming soon'),
        backgroundColor: Color(0xFFE89B8D),
      ),
    );
  }

  void _handleConfirmPayment() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE89B8D),
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      
      // Return success to previous screen
      Navigator.pop(context, {
        'success': true,
        'paymentMethod': _selectedPaymentMethod,
        'amount': _totalAmount,
      });
    });
  }
}

class PaymentMethod {
  final String id;
  final String type;
  final String lastFour;
  final String expiryDate;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.expiryDate,
  });
}
