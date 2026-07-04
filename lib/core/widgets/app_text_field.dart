import 'package:flutter/material.dart';

import 'package:community_care_hub/core/constants/app_colors.dart';

/// A Material 3 text field with outlined border, filled background,
/// animated focus ring, prefix / suffix icons, and built-in validation.
///
/// ```dart
/// AppTextField(
///   controller: _emailCtrl,
///   label: AppStrings.email,
///   hint: AppStrings.emailHint,
///   prefixIcon: Icons.email_outlined,
///   validator: Validators.email,
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.textInputAction,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _hasFocus) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fillColor = isDark
        ? AppColors.darkSurfaceContainer
        : AppColors.neutral50;

    final borderColor = _hasFocus
        ? theme.colorScheme.primary
        : (isDark ? AppColors.neutral700 : AppColors.neutral300);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppColors.neutral100 : AppColors.neutral900,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.neutral500,
          ),
          filled: true,
          fillColor: fillColor,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, size: 22)
              : null,
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  icon: Icon(widget.suffixIcon, size: 22),
                  onPressed: widget.onSuffixTap,
                  splashRadius: 20,
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.maxLines > 1 ? 16 : 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.neutral700 : AppColors.neutral300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.neutral800 : AppColors.neutral200,
            ),
          ),
          errorStyle: TextStyle(
            color: theme.colorScheme.error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          counterStyle: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ),
    );
  }
}
