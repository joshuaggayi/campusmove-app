import 'package:flutter/material.dart';

import '../db.dart';
import '../models.dart';
import '../widgets.dart';
import 'route_detail_screen.dart';

enum SortBy { cheapest, fastest, topRated }

/// Functionality 2 (part 2): compare the route options for a trip.
class ResultsScreen extends StatefulWidget {
  final String origin;
  final String destination;

  const ResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<TransportRoute> _routes = [];
  bool _loading = true;
  SortBy _sort = SortBy.cheapest;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final routes = await AppDatabase.instance
        .searchRoutes(widget.origin, widget.destination);
    if (!mounted) return;
    setState(() {
      _routes = routes;
      _sortRoutes();
      _loading = false;
    });
  }

  void _sortRoutes() {
    switch (_sort) {
      case SortBy.cheapest:
        _routes.sort((a, b) => a.fareUgx.compareTo(b.fareUgx));
        break;
      case SortBy.fastest:
        _routes.sort((a, b) => a.minutes.compareTo(b.minutes));
        break;
      case SortBy.topRated:
        _routes.sort((a, b) => b.avgRating.compareTo(a.avgRating));
        break;
    }
  }

  Future<void> _open(TransportRoute route) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RouteDetailScreen(routeId: route.id),
    ));
    if (mounted) _load(); // ratings may have changed
  }

  Widget _sortChip(String label, SortBy value) {
    return ChoiceChip(
      label: Text(label),
      selected: _sort == value,
      onSelected: (_) => setState(() {
        _sort = value;
        _sortRoutes();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Route options')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _routes.isEmpty
              ? const EmptyState(
                  icon: Icons.alt_route,
                  message: 'No routes for this trip yet. Try another pair of places.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '${widget.origin} → ${widget.destination}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _sortChip('Cheapest', SortBy.cheapest),
                          _sortChip('Fastest', SortBy.fastest),
                          _sortChip('Top rated', SortBy.topRated),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _routes.length,
                        itemBuilder: (context, i) => RouteCard(
                          route: _routes[i],
                          onTap: () => _open(_routes[i]),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
