import 'package:flutter/material.dart';

import '../db.dart';
import '../models.dart';
import '../session.dart';
import '../widgets.dart';
import '../widgets/route_map.dart';
import 'review_form.dart';

/// Functionality 2 (part 3): stage-by-stage guidance plus the route's reviews.
class RouteDetailScreen extends StatefulWidget {
  final int routeId;

  const RouteDetailScreen({super.key, required this.routeId});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  TransportRoute? _route;
  List<RouteStage> _stages = [];
  List<Review> _reviews = [];
  bool _saved = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = AppDatabase.instance;
    final route = await db.getRoute(widget.routeId);
    final stages = await db.getStages(widget.routeId);
    final reviews = await db.getReviewsForRoute(widget.routeId);
    final saved = await db.isSaved(session.user!.id, widget.routeId);
    if (!mounted) return;
    setState(() {
      _route = route;
      _stages = stages;
      _reviews = reviews;
      _saved = saved;
      _loading = false;
    });
  }

  Future<void> _toggleSave() async {
    final nowSaved = await AppDatabase.instance
        .toggleSaved(session.user!.id, widget.routeId);
    if (!mounted) return;
    setState(() => _saved = nowSaved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(nowSaved ? 'Route saved' : 'Route removed from saved')),
    );
  }

  Future<void> _rate() async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ReviewForm(routeId: widget.routeId),
      ),
    );
    if (submitted == true) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Thanks for your review')));
    }
  }

  Future<void> _hide(Review review) async {
    final ok = await confirmRemoveComment(context);
    if (!ok) return;
    await AppDatabase.instance.hideReview(review.id);
    await _load();
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final route = _route;
    final isAdmin = session.user!.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route details'),
        actions: [
          IconButton(
            tooltip: _saved ? 'Remove from saved' : 'Save route',
            icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: route == null ? null : _toggleSave,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : route == null
              ? const EmptyState(
                  icon: Icons.error_outline, message: 'This route was not found.')
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Icon(modeIcon(route.mode),
                                      color:
                                          theme.colorScheme.onPrimaryContainer),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${route.origin} → ${route.destination}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('${route.mode} · ${formatUgx(route.fareUgx)} · '
                                '${route.minutes} min'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                StarRating(rating: route.avgRating),
                                const SizedBox(width: 8),
                                Text(route.reviewCount == 0
                                    ? 'No reviews yet'
                                    : '${route.avgRating.toStringAsFixed(1)} '
                                        '(${route.reviewCount} reviews)'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    _sectionTitle('Where to board'),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.place),
                        title: Text(route.boardingPoint),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Map',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FullMapScreen(
                                  title: '${route.origin} → ${route.destination}',
                                  stages: _stages,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.fullscreen),
                            label: const Text('Full screen'),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: 260,
                        child: RouteMap(stages: _stages),
                      ),
                    ),
                    _sectionTitle('Stages and landmarks'),
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < _stages.length; i++) ...[
                            if (i > 0) const Divider(height: 1),
                            ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                child: Text('${_stages[i].seq}',
                                    style: const TextStyle(fontSize: 12)),
                              ),
                              title: Text(_stages[i].name),
                              subtitle: Text(_stages[i].landmark),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Reviews',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _rate,
                            icon: const Icon(Icons.star_outline),
                            label: const Text('Rate this route'),
                          ),
                        ],
                      ),
                    ),
                    if (_reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No reviews yet. Be the first to rate this route.'),
                      )
                    else
                      for (final r in _reviews)
                        ReviewTile(
                          review: r,
                          onHide: isAdmin ? () => _hide(r) : null,
                        ),
                  ],
                ),
    );
  }
}
