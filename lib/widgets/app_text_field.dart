import 'package:flutter/material.dart';

import '../core/utils/context_ext.dart';

/// Labelled text field with optional password visibility toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscure,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icon == null ? null : Icon(widget.icon),
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
