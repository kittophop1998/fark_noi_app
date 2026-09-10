import 'package:equatable/equatable.dart';

/// One slide of the home carousel — `HomeBanner` on the wire, already filtered
/// to enabled and inside its schedule window by `GET /home-banners/active`.
class HomeBannerEntity extends Equatable {
  const HomeBannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkHref,
  });

  final String id;
  final String title;
  final String imageUrl;

  /// An in-app path or an absolute URL. Null draws a slide nothing happens
  /// when tapped, which is a real banner state — not every promotion links
  /// anywhere.
  final String? linkHref;

  factory HomeBannerEntity.fromJson(Map<String, dynamic> json) {
    return HomeBannerEntity(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      linkHref: (json['linkHref'] as String?)?.isNotEmpty == true
          ? json['linkHref'] as String
          : null,
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, linkHref];
}
