import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

class OpenSourceLicensesScreen extends StatelessWidget {
  const OpenSourceLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Source Credits'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We stand on the shoulders of giants.',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Student Companion is made possible by the incredible work of the open-source community. Below are the major open-source packages and frameworks used to build this application.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            AppCard(
              child: Column(
                children: [
                  _buildPackageTile('Flutter', 'A framework by Google for building beautiful, natively compiled, multi-platform applications from a single codebase.'),
                  const Divider(),
                  _buildPackageTile('Riverpod', 'A reactive caching and data-binding framework that handles state management efficiently and safely.'),
                  const Divider(),
                  _buildPackageTile('Hive', 'A lightweight and blazing fast key-value database written in pure Dart, powering our offline-first architecture.'),
                  const Divider(),
                  _buildPackageTile('Go Router', 'A declarative routing package for Flutter that uses the Router API to provide a convenient, url-based API for navigating.'),
                  const Divider(),
                  _buildPackageTile('Freezed', 'A robust code generator for creating immutable classes and unions in Dart.'),
                  const Divider(),
                  _buildPackageTile('Flutter Local Notifications', 'A cross platform plugin for displaying local notifications.'),
                  const Divider(),
                  _buildPackageTile('Package Info Plus', 'A Flutter plugin for querying information about the application package.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Trademarks belong to their respective owners. Each library operates under its own open-source license (such as MIT, BSD, or Apache 2.0).',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageTile(String title, String description) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(description),
      ),
    );
  }
}
