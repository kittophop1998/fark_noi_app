import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';

/// A person, drawn as a face or as the initial of their name.
///
/// The tinted plate is `primarySoft` with `primaryInkStrong` ink — coral text
/// on a coral tint, which is the pair that clears AA. It is never `primary`:
/// that step is a *shape*, and an initial is a word.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.muted = false,
  });

  final String name;
  final String? imageUrl;
  final double size;

  /// A person whose trip is over — the plate goes grey so the row still reads
  /// as a person without claiming to be live.
  final bool muted;

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: muted ? AppColors.surfaceStrong : AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              // A broken URL falls back to the initial rather than to a
              // broken-image glyph, which reads as the product being broken.
              errorBuilder: (_, __, ___) => _initialPlate(),
            )
          : _initialPlate(),
    );
  }

  Widget _initialPlate() {
    return Center(
      child: Text(
        _initial,
        style: AppText.title.copyWith(
          fontSize: size * 0.42,
          height: 1,
          fontWeight: FontWeight.w700,
          color: muted ? AppColors.faint : AppColors.primaryInkStrong,
        ),
      ),
    );
  }
}

/// Who somebody is: a face, a name, and one quiet line under it.
///
/// On a marketplace between strangers this row is what decides whether the rest
/// of a card is worth reading, so it sits at the top of one.
///
/// There is deliberately **no verified badge**: a tick drawn here would be the
/// client asserting to one stranger that the product had checked another. When
/// verification lands server-side it arrives as a field on the data, the way a
/// rating does.
class UserIdentity extends StatelessWidget {
  const UserIdentity({
    super.key,
    required this.name,
    this.imageUrl,
    this.caption,
    this.trailing,
    this.avatarSize = 40,
    this.muted = false,
  });

  final String name;
  final String? imageUrl;

  /// One line under the name — a rating, a role, a place.
  final Widget? caption;

  /// The end of the row: a distance pill, a badge, a control.
  final Widget? trailing;

  final double avatarSize;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(
          name: name,
          imageUrl: imageUrl,
          size: avatarSize,
          muted: muted,
        ),
        const SizedBox(width: AppSpace.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.label.copyWith(color: AppColors.text),
              ),
              if (caption != null) ...[
                const SizedBox(height: 2),
                caption!,
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpace.x2),
          trailing!,
        ],
      ],
    );
  }
}

/// A rating the API sent, and only ever one the API sent.
///
/// **An unrated person is drawn as new, never as 0.0** — a zero printed on
/// every card in a feed reads as a warning about half the platform. That is why
/// [rated] is a separate flag rather than a `rating == 0` test.
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    required this.rated,
    this.reviewCount,
  });

  final double rating;
  final bool rated;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    if (!rated) {
      return Text(
        'ยังไม่มีรีวิว',
        style: AppText.caption.copyWith(color: AppColors.faint),
      );
    }

    final count = reviewCount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.rating),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: AppText.caption.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (count != null && count > 0) ...[
          const SizedBox(width: 3),
          Text(
            '($count)',
            style: AppText.caption.copyWith(color: AppColors.faint),
          ),
        ],
      ],
    );
  }
}
