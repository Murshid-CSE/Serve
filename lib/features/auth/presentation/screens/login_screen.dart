import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:community_care_hub/features/auth/presentation/widgets/auth_form.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/utils/validators.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await ref.read(authActionsProvider).signInWithEmail(
            _emailController.text,
            _passwordController.text,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('Welcome back, ${user.name}!');
      
      if (user.role == 'donor' || user.role == 'volunteer' || user.role == 'both' || user.role == 'admin') {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.roleSelection);
      }
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final user = await ref.read(authActionsProvider).signInWithGoogle();

      if (!mounted) return;
      context.showSuccessSnackBar('Signed in with Google as ${user.name}');
      
      // If user is brand new or hasn't selected a role
      if (user.role == 'donor' || user.role == 'volunteer' || user.role == 'both' || user.role == 'admin') {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.roleSelection);
      }
    } catch (e) {
      if (!mounted) return;
      if (!e.toString().contains('cancelled')) {
        context.showErrorSnackBar(e.toString().replaceAll('AppException(auth-error): ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // Large curved gradient header
              Container(
                height: size.height * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.heroGradient,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Care Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'One Platform. One Coordinated Workflow.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // White overlapping card
              Positioned(
                top: size.height * 0.30,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          AuthFormField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AuthFormField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: Validators.validatePassword,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.push(AppRoutes.forgotPassword);
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Login',
                            onPressed: _isLoading ? null : _handleLogin,
                            isLoading: _isLoading,
                            isExpanded: true,
                            variant: AppButtonVariant.filled,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: const [
                              Expanded(
                                child: Divider(color: AppColors.neutral300),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: AppColors.neutral500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: AppColors.neutral300),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GoogleSignInButton(
                            onPressed: _isGoogleLoading ? () {} : _handleGoogleSignIn,
                            isLoading: _isGoogleLoading,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(color: AppColors.neutral600),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push(AppRoutes.register);
                                },
                                child: const Text(
                                  'Register Now',
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
            ],
          ),
        ),
      ),
    );
  }
}
