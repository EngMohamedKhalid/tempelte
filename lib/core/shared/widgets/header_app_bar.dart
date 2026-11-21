import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../style/app_size.dart';
import 'header_band.dart';

/// The F26 navy band in a Scaffold's `appBar` slot.
///
/// A screen swaps `AppBar(title: Text(t))` for `HeaderAppBar(title: t)` and
/// keeps its body as it is. A back button appears by itself on any route that
/// can pop, as AppBar's does.
class HeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderAppBar({
    required this.title,
    this.eyebrow,
    this.icon,
    this.actions = const <Widget>[],
    this.tone = HeaderTone.customer,
    this.showBack,
    super.key,
  });

  final String title;
  final String? eyebrow;

  /// The screen's glyph, on the band's green tile.
  final IconData? icon;
  final List<Widget> actions;
  final HeaderTone tone;

  /// Null: decided by whether the route can pop.
  final bool? showBack;

  @override
  Size get preferredSize => Size.fromHeight(AppSize.getSize(48) + AppSize.getHeight(eyebrow == null ? 36 : 44));

  @override
  Widget build(BuildContext context) {
    final bool back = showBack ?? (ModalRoute.of(context)?.impliesAppBarDismissal ?? false);
    return SizedBox.expand(
      child: HeaderBand(
        title: title,
        eyebrow: eyebrow,
        icon: icon,
        tone: tone,
        compact: true,
        actions: actions,
        leading: back
            ? HeaderAction(
                icon: Icons.arrow_back_rounded,
                semanticLabel: 'core.back'.tr(),
                onTap: () => Navigator.of(context).maybePop(),
                round: true,
              )
            : null,
      ),
    );
  }
}
