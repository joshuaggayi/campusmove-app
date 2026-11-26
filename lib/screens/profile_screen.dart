import 'package:flutter/material.dart';

import '../db.dart';
import '../session.dart';

/// Profile: account details, activity counts and logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _saved = 0;
  int _reviews = 0;

  @override
  void initState() {
    super.initState();
    AppDatabase.instance.version.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppDatabase.instance.version.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final user = session.user;
    if (user == null) return;
    final saved = await AppDatabase.instance.countSaved(user.id);
    final reviews = await AppDatabase.instance.countReviewsBy(user.id);
    if (!mounted) return;
    setState(() {
      _saved = saved;
      _reviews = reviews;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = session.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(user.email, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: Icon(user.isAdmin
                  ? Icons.admin_panel_settings_outlined
                  : Icons.school_outlined),
              label: Text(user.isAdmin ? 'Admin' : 'Student / Commuter'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: const Text('Saved routes'),
                  trailing: Text('$_saved'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined),
                  title: const Text('Reviews written'),
                  trailing: Text('$_reviews'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => session.signOut(),
            icon: const Icon(Icons.logout),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Log out'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Route fares and times in this version are sample data stored on '
            'your phone.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
