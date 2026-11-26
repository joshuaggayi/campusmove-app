import 'package:flutter/material.dart';

import 'models.dart';

IconData modeIcon(String mode) {
  switch (mode) {
    case 'Taxi':
      return Icons.local_taxi;
    case 'Boda boda':
      return Icons.two_wheeler;
    case 'Bus':
      return Icons.directions_bus;
    default:
      return Icons.alt_route;
  }
}

String formatUgx(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'UGX $buf';
}

String formatDate(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day/$month/${d.year}';
}

Future<bool> confirmRemoveComment(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove this comment?'),
      content: const Text('It will no longer be shown to other users.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Read-only star display (supports half stars).
class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final v = rating - i;
        final IconData icon = v >= 0.75
            ? Icons.star
            : (v >= 0.25 ? Icons.star_half : Icons.star_border);
        return Icon(icon, size: size, color: Colors.amber.shade700);
      }),
    );
  }
}

/// Tappable 1 to 5 star selector.
class StarPicker extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const StarPicker({super.key, required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return IconButton(
          onPressed: () => onChanged(i + 1),
          tooltip: '${i + 1} star${i == 0 ? '' : 's'}',
          icon: Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: Colors.amber.shade700,
            size: 34,
          ),
        );
      }),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final TransportRoute route;
  final VoidCallback onTap;
  final bool showEndpoints;

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
    this.showEndpoints = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(modeIcon(route.mode),
                    color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showEndpoints
                          ? '${route.origin} → ${route.destination}'
                          : route.mode,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (showEndpoints) Text(route.mode),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.payments_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text(formatUgx(route.fareUgx)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 16),
                            const SizedBox(width: 4),
                            Text('${route.minutes} min'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StarRating(rating: route.avgRating, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          route.reviewCount == 0
                              ? 'No reviews yet'
                              : '${route.avgRating.toStringAsFixed(1)} (${route.reviewCount})',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  final Review review;
  final bool showRoute;
  final VoidCallback? onHide; // only given to admins
  final VoidCallback? onTap;

  const ReviewTile({
    super.key,
    required this.review,
    this.showRoute = false,
    this.onHide,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StarRating(rating: review.rating.toDouble(), size: 18),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(review.tag),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  const Spacer(),
                  if (onHide != null)
                    IconButton(
                      tooltip: 'Remove comment',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onHide,
                    ),
                ],
              ),
              if (showRoute && review.routeLabel.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    review.routeLabel,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(review.comment),
              ),
              const SizedBox(height: 6),
              Text(
                '${review.userName} · ${formatDate(review.createdAt)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
