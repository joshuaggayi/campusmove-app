class AppUser {
  final int id;
  final String name;
  final String email;
  final String role; // 'Student' or 'Admin'

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'Admin';

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        id: m['id'] as int,
        name: m['name'] as String,
        email: m['email'] as String,
        role: m['role'] as String,
      );
}

class TransportRoute {
  final int id;
  final String origin;
  final String destination;
  final String mode; // 'Taxi', 'Boda boda' or 'Bus'
  final int fareUgx;
  final int minutes;
  final String boardingPoint;
  final double avgRating;
  final int reviewCount;

  const TransportRoute({
    required this.id,
    required this.origin,
    required this.destination,
    required this.mode,
    required this.fareUgx,
    required this.minutes,
    required this.boardingPoint,
    required this.avgRating,
    required this.reviewCount,
  });

  factory TransportRoute.fromMap(Map<String, Object?> m) => TransportRoute(
        id: m['id'] as int,
        origin: m['origin'] as String,
        destination: m['destination'] as String,
        mode: m['mode'] as String,
        fareUgx: m['fare_ugx'] as int,
        minutes: m['minutes'] as int,
        boardingPoint: m['boarding_point'] as String,
        avgRating: ((m['avg_rating'] ?? 0) as num).toDouble(),
        reviewCount: (m['review_count'] ?? 0) as int,
      );
}

class RouteStage {
  final int seq;
  final String name;
  final String landmark;

  const RouteStage({
    required this.seq,
    required this.name,
    required this.landmark,
  });

  factory RouteStage.fromMap(Map<String, Object?> m) => RouteStage(
        seq: m['seq'] as int,
        name: m['stage_name'] as String,
        landmark: m['landmark'] as String,
      );
}

class Review {
  final int id;
  final int routeId;
  final String userName;
  final int rating;
  final String comment;
  final String tag;
  final DateTime createdAt;
  final String routeLabel; // empty when not loaded with a route

  const Review({
    required this.id,
    required this.routeId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.tag,
    required this.createdAt,
    required this.routeLabel,
  });

  factory Review.fromMap(Map<String, Object?> m) => Review(
        id: m['id'] as int,
        routeId: m['route_id'] as int,
        userName: m['user_name'] as String,
        rating: m['rating'] as int,
        comment: m['comment'] as String,
        tag: m['tag'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        routeLabel: (m['route_label'] as String?) ?? '',
      );
}
