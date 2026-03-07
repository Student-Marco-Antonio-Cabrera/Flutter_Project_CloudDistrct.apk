import 'package:flutter/material.dart';

/// A reusable password [TextFormField] with a show/hide toggle.
/// Drop-in replacement for any password field — just swap
/// [TextFormField] with [PasswordField].
///
/// Also fixes the label-wrapping bug: labels are kept short and
/// [floatingLabelBehavior] is set to [FloatingLabelBehavior.auto]
/// so they always float up instead of wrapping inside the field.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.done,
    this.prefixIcon = const Icon(Icons.lock_outline_rounded),
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final Widget prefixIcon;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        // Show/hide toggle on the right
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        // Float the label so it never wraps inside the field
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}