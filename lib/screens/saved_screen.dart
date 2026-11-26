import 'package:flutter/material.dart';

import '../db.dart';
import '../models.dart';
import '../session.dart';
import '../widgets.dart';
import 'route_detail_screen.dart';

/// Routes the user has bookmarked.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<TransportRoute> _routes = [];
  bool _loading = true;

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
    final routes = await AppDatabase.instance.getSavedRoutes(user.id);
    if (!mounted) return;
    setState(() {
      _routes = routes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved routes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _routes.isEmpty
              ? const EmptyState(
                  icon: Icons.bookmark_border,
                  message:
                      'No saved routes yet. Tap the bookmark on a route to keep it here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _routes.length,
                  itemBuilder: (context, i) => RouteCard(
                    route: _routes[i],
                    showEndpoints: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RouteDetailScreen(routeId: _routes[i].id),
                      ),
                    ),
                  ),
                ),
    );
  }
}
