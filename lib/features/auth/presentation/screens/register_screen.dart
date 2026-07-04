import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/auth/presentation/widgets/auth_form.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authActionsProvider).registerWithEmail(
            _nameController.text,
            _emailController.text,
            _phoneController.text,
            _passwordController.text,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('Account created successfully!');
      context.go(AppRoutes.roleSelection);
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString().replaceAll('AppException(auth-error): ', '').replaceAll('AppException(network-error): ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Join Us Today',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start contributing to your community with a single coordinated workflow.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: Validators.validateName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  AuthFormField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  AuthFormField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your 10-digit phone number',
                    prefixIcon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  AuthFormField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Create a password (min 6 characters)',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: Validators.validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  AuthFormField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Register',
                    onPressed: _isLoading ? null : _handleRegister,
                    isLoading: _isLoading,
                    isExpanded: true,
                    variant: AppButtonVariant.filled,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: AppColors.neutral600),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          'Login Now',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
