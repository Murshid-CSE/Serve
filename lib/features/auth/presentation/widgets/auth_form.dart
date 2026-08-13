import 'package:flutter/material.dart';
import 'package:community_care_hub/core/widgets/app_text_field.dart';

class AuthFormField extends StatefulWidget {

  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.textInputAction,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final TextInputAction? textInputAction;

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      prefixIcon: widget.prefixIcon,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? _obscureText : false,
      textInputAction: widget.textInputAction,
      suffixIcon: widget.isPassword
          ? (_obscureText ? Icons.visibility_off : Icons.visibility)
          : null,
      onSuffixTap: widget.isPassword
          ? () {
              setState(() {
                _obscureText = !_obscureText;
              });
            }
          : null,
    );
  }
}
