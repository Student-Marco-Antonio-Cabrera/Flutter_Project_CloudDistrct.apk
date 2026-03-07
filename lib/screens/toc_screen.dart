import 'package:flutter/material.dart';

class TocScreen extends StatelessWidget {
  const TocScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Terms and Conditions',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'By using this Cloud District application you agree to the following terms:\n\n'
              '1. You must be of legal age to purchase vaping products in your jurisdiction.\n\n'
              '2. Products are for personal use only. Resale may be subject to local regulations.\n\n'
              '3. We process orders as quickly as possible. Delivery times may vary.\n\n'
              '4. Your personal information is stored locally on your device and used only to fulfill orders and improve your experience.\n\n'
              '5. You may edit or delete your profile and addresses at any time from the Profile section.\n\n'
              '6. By placing an order you confirm that the information provided is accurate and that you accept these terms.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Return'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
