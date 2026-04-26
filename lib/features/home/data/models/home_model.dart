import '../../domain/entities/home_entity.dart';

class HomeModel extends HomeEntity {
  const HomeModel({
    required super.id,
    required super.name,
    required super.avatarInitial,
    required super.destination,
    required super.dormitory,
    required super.departureTime,
    required super.totalSlots,
    required super.filledSlots,
    super.rating = 5.0,
    super.reviewCount = 0,
    super.eta = '',
    super.tags = const [],
    super.category = 'food',
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
        id: json['id'] as int,
        name: json['name'] as String,
        avatarInitial: json['avatar_initial'] as String? ?? '',
        destination: json['destination'] as String,
        dormitory: json['dormitory'] as String? ?? '',
        departureTime: json['departure_time'] as String,
        totalSlots: json['total_slots'] as int,
        filledSlots: json['filled_slots'] as int,
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        reviewCount: json['review_count'] as int? ?? 0,
        eta: json['eta'] as String? ?? '',
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        category: json['category'] as String? ?? 'food',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_initial': avatarInitial,
        'destination': destination,
        'dormitory': dormitory,
        'departure_time': departureTime,
        'total_slots': totalSlots,
        'filled_slots': filledSlots,
        'rating': rating,
        'review_count': reviewCount,
        'eta': eta,
        'tags': tags,
        'category': category,
      };
}
