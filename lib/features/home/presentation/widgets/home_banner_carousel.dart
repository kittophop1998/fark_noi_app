import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/home_banner_entity.dart';

/// The home feed's one hero slide-show — a promotion, an announcement, never
/// more than [HomeBannerEntity]s the server actually chose to show right now.
///
/// A [PageView] and not a [ListView]: a promotion is meant to be looked at one
/// at a time, the way the web's carousel snaps a slide to the viewport rather
/// than letting two half-slides sit side by side.
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key, required this.banners});

  final List<HomeBannerEntity> banners;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 132,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _BannerSlide(banner: widget.banners[i]),
            ),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: AppSpace.x2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.banners.length; i++)
                AnimatedContainer(
                  duration: AppMotion.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.brand
                        : AppColors.borderStrong,
                    borderRadius: AppRadius.brPill,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.banner});

  final HomeBannerEntity banner;

  @override
  Widget build(BuildContext context) {
    // Only an in-app route is navigable here — an absolute URL is a real
    // banner state (see [HomeBannerEntity.linkHref]) but this app has no
    // external-browser launcher wired up, so it draws as a slide that simply
    // does not respond rather than one that fails silently on tap.
    final href = banner.linkHref;
    final inAppRoute = href != null && href.startsWith('/');

    return ClipRRect(
      borderRadius: AppRadius.brXl2,
      child: Material(
        color: AppColors.surfaceStrong,
        child: InkWell(
          onTap: inAppRoute ? () => context.push(href) : null,
          child: Ink(
            decoration: BoxDecoration(boxShadow: AppShadow.xs),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceStrong,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.muted,
                    ),
                  ),
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : Container(color: AppColors.surfaceStrong),
                ),
                if (banner.title.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.x4,
                        AppSpace.x6,
                        AppSpace.x4,
                        AppSpace.x3,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x99000000)],
                        ),
                      ),
                      child: Text(
                        banner.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
