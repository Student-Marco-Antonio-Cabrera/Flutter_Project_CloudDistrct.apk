import 'package:flutter/material.dart';

/// A reusable email [TextFormField].
/// Fixes the label-wrapping bug by using [floatingLabelBehavior.auto]
/// and keeping the label text concise.
class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    this.controller,
    this.label = 'Email',
    this.hint = 'Enter your email',
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon = const Icon(Icons.email_outlined),
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final Widget prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        // Float label so it never wraps inside the field
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}