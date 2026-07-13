import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_info.dart';
import '../../../../core/widgets/widgets.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: July 14, 2026\nApp Version: ${appInfo.version}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Introduction'),
            AppCard(
              child: Text(
                'Student Companion is designed with privacy as a foundational principle. We believe that your academic information—such as attendance, GPA, and marks—belongs to you and you alone. This application operates as an offline-first tool, ensuring maximum data security.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Information We Collect'),
            AppCard(
              child: Text(
                'We do not collect any personal data. All information you input into Student Companion (such as subjects, attendance logs, timetables, and grading scales) is stored locally on your device.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Information We Do Not Collect'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(theme, 'No background tracking.'),
                  _buildBulletPoint(theme, 'No location tracking.'),
                  _buildBulletPoint(theme, 'No access to your contacts.'),
                  _buildBulletPoint(theme, 'No access to your microphone or camera.'),
                  _buildBulletPoint(theme, 'No analytics or crash reporting SDKs that send data to remote servers.'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Offline Data Storage'),
            AppCard(
              child: Text(
                'Your data is securely stored within the app\'s private sandbox on your device using an encrypted local database system (Hive). Your academic information is never uploaded to developer servers. No account creation is required to use this application.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Permissions Used'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Permission:',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Used strictly for local device reminders (e.g., class reminders, attendance alerts, assignment deadlines). The scheduling occurs locally on your phone.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Data Security'),
            AppCard(
              child: Text(
                'Because the data never leaves your device, security is handled by your operating system. We recommend keeping your device protected with a passcode or biometric lock. You have full control to backup or export your data via the Settings menu.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Third-Party Libraries & Ads'),
            AppCard(
              child: Text(
                'Student Companion does not display third-party advertisements. We utilize several open-source libraries (e.g., Flutter, Riverpod, Hive) to build this application. Each library operates locally and follows its own open-source license.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Future Cloud Features'),
            AppCard(
              child: Text(
                'If cloud synchronization is introduced in the future, it will be strictly an opt-in feature requiring explicit user consent. Until then, the application will remain 100% offline.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'User Rights & Contact'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You have the right to delete all your data at any time by simply uninstalling the application or clearing its local storage data.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'For questions regarding this privacy policy, please contact:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: sundram.devv@gmail.com',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: theme.textTheme.bodyLarge),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
