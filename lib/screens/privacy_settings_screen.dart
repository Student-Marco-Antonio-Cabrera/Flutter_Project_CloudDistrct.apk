import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_scaffold.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});
  static const String routeName = '/privacy-settings';
  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  Future<void> _showChangePasswordDialog(AuthProvider auth) async {
    if (!auth.canChangePassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password change is only available for email/password accounts.',
          ),
        ),
      );
      return;
    }
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    try {
      final result = await showDialog<PasswordChangeResult>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Minimum 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your new password';
                    }
                    if (value != newController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final changeResult = await auth.changePassword(
                  currentPassword: currentController.text,
                  newPassword: newController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context, changeResult);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (!mounted || result == null) return;
      final message = switch (result) {
        PasswordChangeResult.success => 'Password updated successfully.',
        PasswordChangeResult.notLoggedIn => 'You are not logged in.',
        PasswordChangeResult.unsupportedAccount =>
          'This account does not support password changes.',
        PasswordChangeResult.wrongCurrentPassword =>
          'Current password is incorrect.',
        PasswordChangeResult.weakPassword => 'New password is too weak.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    }
  }

  Future<void> _toggleTwoFactor({
    required bool value,
    required AuthProvider auth,
  }) async {
    if (!value) {
      await auth.setTwoFactorEnabled(false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Two-factor authentication disabled.')),
      );
      return;
    }
    final code = auth.startTwoFactorSetup();
    if (code.isEmpty) return;
    final codeController = TextEditingController();
    try {
      final enteredCode = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Two-Factor Authentication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Demo verification code: $code',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the code to finish enabling 2FA.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '6-digit code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, codeController.text),
              child: const Text('Verify'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (enteredCode == null) {
        auth.cancelTwoFactorSetup();
        return;
      }
      final enabled = await auth.confirmTwoFactorSetup(enteredCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Two-factor authentication is now enabled.'
                : 'Invalid or expired code. 2FA was not enabled.',
          ),
        ),
      );
    } finally {
      codeController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.white.withValues(alpha: 0.16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.26)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.lock_reset_outlined,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Change Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      auth.canChangePassword
                          ? 'Update your sign-in credentials'
                          : 'Unavailable for social sign-in accounts',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                    onTap: () => _showChangePasswordDialog(auth),
                  ),
                  const Divider(height: 1, color: Colors.white38),
                  SwitchListTile(
                    value: auth.isTwoFactorEnabled,
                    onChanged: (value) =>
                        _toggleTwoFactor(value: value, auth: auth),
                    secondary: const Icon(
                      Icons.security_outlined,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Two-Factor Authentication',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Require a one-time code during login',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.white38,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withValues(alpha: 0.16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.26)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Privacy Controls',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'More privacy options can be connected later',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Privacy controls are ready for expansion.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
