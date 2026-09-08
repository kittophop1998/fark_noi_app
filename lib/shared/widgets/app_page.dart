import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import 'app_page_header.dart';

/// The shape of every screen.
///
/// ```dart
/// AppPage(
///   title: 'หน้าแรก',
///   children: [ AppSection(...), AppSection(...) ],
///   footer: AppButton(label: '…', size: AppButtonSize.large, fullWidth: true),
/// )
/// ```
///
/// The header is the shell's, never the screen's — a screen that renders its
/// own stacks two. The page gutter and the seam under the band are single
/// numbers here so no screen has to remember them.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.tone = PageHeaderTone.brand,
    this.showBell = true,
    this.unreadCount = 0,
    this.onBellTap,
    this.userName,
    this.userImageUrl,
    this.onIdentityTap,
    this.showBack = false,
    this.onBack,
    this.footer,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;

  final PageHeaderTone tone;
  final bool showBell;
  final int unreadCount;
  final VoidCallback? onBellTap;
  final String? userName;
  final String? userImageUrl;
  final VoidCallback? onIdentityTap;
  final bool showBack;
  final VoidCallback? onBack;

  /// The committing action, pinned above the fold of the screen rather than at
  /// the end of the scroll — a form's submit, a request's confirm.
  final Widget? footer;

  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppPageHeader(
            title: title,
            tone: tone,
            showBell: showBell,
            unreadCount: unreadCount,
            onBellTap: onBellTap,
            userName: userName,
            userImageUrl: userImageUrl,
            onIdentityTap: onIdentityTap,
            showBack: showBack,
            onBack: onBack,
          ),
          Expanded(child: child),
          if (footer != null) AppStickyFooter(child: footer!),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// The committing action's bar.
///
/// It sits on the page's own surface with a hairline above it and a raised
/// shadow, so content scrolling under it is visibly *under* it. The safe-area
/// inset is added here rather than by the caller — a button whose bottom half
/// is behind a home indicator is a button that gets mis-tapped.
class AppStickyFooter extends StatelessWidget {
  const AppStickyFooter({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpace.pageX,
      AppSpace.x3,
      AppSpace.pageX,
      AppSpace.x3,
    ),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: padding.copyWith(bottom: padding.bottom + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        boxShadow: AppShadow.sm,
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// The standard scroll body: the page gutter on both sides, the section rhythm
/// of air under the band, and enough room at the foot that the last card clears
/// a bottom bar.
class AppPageContent extends StatelessWidget {
  const AppPageContent({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.onRefresh,
  });

  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsets? padding;

  /// Pull to refresh, in the product's coral.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      controller: controller,
      padding: padding ??
          const EdgeInsets.fromLTRB(
            AppSpace.pageX,
            AppSpace.sectionGap,
            AppSpace.pageX,
            AppSpace.x8,
          ),
      children: children,
    );

    if (onRefresh == null) return list;
    return RefreshIndicator(
      onRefresh: onRefresh!,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: list,
    );
  }
}
