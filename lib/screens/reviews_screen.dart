import 'package:flutter/material.dart';

import '../db.dart';
import '../models.dart';
import '../session.dart';
import '../widgets.dart';
import 'route_detail_screen.dart';

/// Functionality 3: community reviews across all routes. Admins can remove comments.
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> _reviews = [];
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
    final reviews = await AppDatabase.instance.getRecentReviews();
    if (!mounted) return;
    setState(() {
      _reviews = reviews;
      _loading = false;
    });
  }

  Future<void> _hide(Review review) async {
    final ok = await confirmRemoveComment(context);
    if (!ok) return;
    await AppDatabase.instance.hideReview(review.id);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = session.user!.isAdmin;
    return Scaffold(
      appBar: AppBar(title: const Text('Community reviews')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? const EmptyState(
                  icon: Icons.rate_review_outlined,
                  message: 'No reviews yet. Open a route and rate it.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (isAdmin)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Admin: use the bin icon to remove an unhelpful comment.',
                          ),
                        ),
                      for (final r in _reviews)
                        ReviewTile(
                          review: r,
                          showRoute: true,
                          onHide: isAdmin ? () => _hide(r) : null,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RouteDetailScreen(routeId: r.routeId),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
