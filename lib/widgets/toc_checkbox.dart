import 'package:flutter/material.dart';

class TocCheckbox extends StatelessWidget {
  const TocCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.message,
    required this.onTocTap,
  });
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String message;
  final VoidCallback onTocTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return Colors.white;
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 13,
                ),
                children: [
                  TextSpan(text: message),
                  const TextSpan(text: ' '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onTocTap,
                      child: const Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
