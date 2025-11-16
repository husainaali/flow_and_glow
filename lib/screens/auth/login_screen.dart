import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../customer/customer_home_screen.dart';
import '../center_admin/center_admin_dashboard.dart';
import '../super_admin/super_admin_dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isLoginSelected = true;

  // Registration form controllers and state
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  UserRole _registerSelectedRole = UserRole.customer;
  bool _isRegisterLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo (smaller)
                Container(
                  width: 180,
                  height: 180,

                  child: Center(
                    child: Image.asset(
                      'assets/images/FlowGlow.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
               
                const SizedBox(height: 40),
                // Tab selector with animated toggle
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Stack(
                    children: [
                      // Animated background pill
                      AnimatedAlign(
                        alignment: _isLoginSelected
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      // Labels and tap areas
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                if (!_isLoginSelected) {
                                  setState(() {
                                    _isLoginSelected = true;
                                  });
                                }
                              },
                              child: Center(
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _isLoginSelected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                if (_isLoginSelected) {
                                  setState(() {
                                    _isLoginSelected = false;
                                  });
                                }
                              },
                              child: Center(
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: !_isLoginSelected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Animated login / register forms
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    // Slight slide + fade for smoother feel
                    final offsetTween = Tween<Offset>(
                      begin: const Offset(0.0, 0.08),
                      end: Offset.zero,
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetTween.animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _isLoginSelected
                      ? _buildLoginFormFields()
                      : _buildRegisterFormFields(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // LOGIN FORM WIDGET
  Widget _buildLoginFormFields() {
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        _AnimatedField(
          delayMilliseconds: 0,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'User Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textLight),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        // Password field
        _AnimatedField(
          delayMilliseconds: 80,
          child: TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textLight),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        // Remember me
        _AnimatedField(
          delayMilliseconds: 160,
          child: Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.accent,
              ),
              const Text(
                'Remember me',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Login button
        _AnimatedField(
          delayMilliseconds: 240,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : const Text('Login'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedField(
          delayMilliseconds: 320,
          child: TextButton(
            onPressed: () {
              // TODO: Implement forgot password
            },
            child: const Text(
              'Forgot password?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  // REGISTER FORM WIDGET
  Widget _buildRegisterFormFields() {
    return Column(
      key: const ValueKey('register_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        _AnimatedField(
          delayMilliseconds: 0,
          child: TextFormField(
            controller: _registerNameController,
            decoration: const InputDecoration(
              hintText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textLight),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        // Email field
        _AnimatedField(
          delayMilliseconds: 80,
          child: TextFormField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textLight),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        // Password field
        _AnimatedField(
          delayMilliseconds: 160,
          child: TextFormField(
            controller: _registerPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textLight),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        // Confirm password field
        _AnimatedField(
          delayMilliseconds: 240,
          child: TextFormField(
            controller: _registerConfirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textLight),
            ),
            validator: (value) {
              if (value != _registerPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        // Role selection
        _AnimatedField(
          delayMilliseconds: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'I am a:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildRoleOption(
                      'Customer',
                      UserRole.customer,
                      Icons.person,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRoleOption(
                      'Center Admin',
                      UserRole.centerAdmin,
                      Icons.business,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Register button
        _AnimatedField(
          delayMilliseconds: 400,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRegisterLoading ? null : _handleRegister,
              child: _isRegisterLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : const Text('Register'),
            ),
          ),
        ),
      ],
    );
  }

  // Role option builder reusing styles
  Widget _buildRoleOption(String label, UserRole role, IconData icon) {
    final isSelected = _registerSelectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _registerSelectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.primary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textLight,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isRegisterLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.register(
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        name: _registerNameController.text.trim(),
        role: _registerSelectedRole,
      );

      if (user != null && mounted) {
        // Navigate based on user role
        Widget homeScreen;
        switch (user.role) {
          case UserRole.customer:
            homeScreen = const CustomerHomeScreen();
            break;
          case UserRole.centerAdmin:
            homeScreen = const CenterAdminDashboard();
            break;
          case UserRole.superAdmin:
            homeScreen = const SuperAdminDashboard();
            break;
        }
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => homeScreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegisterLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        // Navigate based on user role
        Widget destination;
        switch (user.role) {
          case UserRole.customer:
            destination = const CustomerHomeScreen();
            break;
          case UserRole.centerAdmin:
            destination = const CenterAdminDashboard();
            break;
          case UserRole.superAdmin:
            destination = const SuperAdminDashboard();
            break;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }
}

// Simple helper for per-field staggered fade/slide-in
class _AnimatedField extends StatelessWidget {
  final int delayMilliseconds;
  final Widget child;

  const _AnimatedField({
    required this.delayMilliseconds,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + delayMilliseconds),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
