import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_info.dart';
import '../../../../core/widgets/widgets.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 100,
              width: 100,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
            const SizedBox(height: 16),
            Text(
              appInfo.appName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Your Ultimate Offline Academic Assistant',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Version ${appInfo.version} (Build ${appInfo.buildNumber})',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 32),

            const SectionHeader(title: 'Description'),
            AppCard(
              child: Text(
                'Student Companion is designed to solve the everyday organizational challenges faced by students. It empowers you to manage attendance, track GPA, predict bunks, and organize your academic life locally on your device without needing an internet connection.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Mission Statement'),
            AppCard(
              child: Text(
                'Our mission is to provide an intuitive, privacy-first, offline tool that helps students maximize their productivity and academic success while keeping their data completely secure and private.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Technology & Open Source'),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.code_rounded),
                    title: const Text('Tech Stack'),
                    subtitle: const Text('Flutter, Riverpod, Hive, GoRouter, Freezed'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.gavel_rounded),
                    title: const Text('License'),
                    subtitle: const Text('MIT License'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.public_rounded),
                    title: const Text('Open Source Notice'),
                    subtitle: const Text('Student Companion is proudly an open-source project.'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.map_rounded),
                    title: const Text('Future Roadmap'),
                    subtitle: const Text('PDF reports, localization, exam timers.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Developer Details'),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_rounded),
                    title: const Text('Developer'),
                    subtitle: const Text('Sundramdotdev'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_rounded),
                    title: const Text('Contact'),
                    subtitle: const Text('sundram.devv@gmail.com'),
                    onTap: () => _launchUrl('mailto:sundram.devv@gmail.com', context),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link_rounded),
                    title: const Text('GitHub Repository'),
                    subtitle: const Text('github.com/sundramdotdev/student_companion'),
                    onTap: () => _launchUrl('https://github.com/sundramdotdev/student_companion', context),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.work_rounded),
                    title: const Text('Portfolio'),
                    subtitle: const Text('github.com/sundramdotdev'),
                    onTap: () => _launchUrl('https://github.com/sundramdotdev', context),
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
}
