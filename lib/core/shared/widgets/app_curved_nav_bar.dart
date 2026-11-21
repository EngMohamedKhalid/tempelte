import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';

/// One tab: its idle and active glyphs and its (already translated) name.
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// The app's tab bar (owner, 2026-11-18): a `curved_navigation_bar` in the
/// shell's header navy, the active tab rising in a green bubble.
///
/// The package draws icons only, so the idle tabs carry their name under the
/// glyph, and the active tab — alone in its bubble — keeps its name for screen
/// readers. Both shells use this one widget, so they cannot drift apart.
class AppCurvedNavBar extends StatelessWidget {
  const AppCurvedNavBar({
    required this.items,
    required this.index,
    required this.barColor,
    required this.onTap,
    super.key,
  });

  final List<AppNavItem> items;
  final int index;

  /// The shell's header navy, so the bar reads as the band's other end.
  final Color barColor;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // The bar has a fixed height; the home-indicator strip below it is the
    // bar's own navy rather than page ground.
    return ColoredBox(
      color: barColor,
      child: SafeArea(
        top: false,
        child: ColoredBox(
          color: AppColors.backgroundPrimary,
          child: CurvedNavigationBar(
            index: index,
            height: AppSize.getHeight(64).clamp(0, 75).toDouble(),
            color: barColor,
            buttonBackgroundColor: AppColors.brand500,
            // The ground showing through the curve's notch is the page's.
            backgroundColor: AppColors.backgroundPrimary,
            animationDuration: const Duration(milliseconds: 350),
            onTap: onTap,
            items: <Widget>[
              for (int i = 0; i < items.length; i++)
                i == index
                    ? AppNavBubbleIcon(item: items[i])
                    : AppNavIdleTab(item: items[i]),
            ],
          ),
        ),
      ),
    );
  }
}

/// The active tab, inside the green bubble.
class AppNavBubbleIcon extends StatelessWidget {
  const AppNavBubbleIcon({required this.item, super.key});

  final AppNavItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.label,
      selected: true,
      button: true,
      child: Icon(item.activeIcon, size: AppSize.getSize(26), color: AppColors.navy950),
    );
  }
}

/// An idle tab: the glyph with its name beneath.
class AppNavIdleTab extends StatelessWidget {
  const AppNavIdleTab({required this.item, super.key});

  final AppNavItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Padding(
        padding: AppSize.padding(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(item.icon, size: AppSize.getSize(22), color: AppColors.navy200),
            SizedBox(height: AppSize.getHeight(2)),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: AppColors.navy200,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
