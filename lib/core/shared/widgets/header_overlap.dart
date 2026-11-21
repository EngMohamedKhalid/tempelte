import 'package:flutter/material.dart';

import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import 'header_band.dart';

/// A [HeaderBand] with the screen's first cards lifted over its lower edge
/// (F26 detail screens and the staff counters).
///
/// The band must be built with `extendBelow` equal to [overlap]. The lift is
/// a paint-time translate, so the scroll extent keeps [overlap] of empty space
/// at its end — invisible under the screen's bottom padding.
class HeaderOverlap extends StatelessWidget {
  const HeaderOverlap({
    required this.header,
    required this.children,
    this.overlap = 52,
    this.gap = AppSpacing.gapM,
    super.key,
  });

  final HeaderBand header;
  final List<Widget> children;
  final double overlap;

  /// Space between [children]: `gapM` between cards, `gapXl` between the
  /// sections of a detail screen (AGENTS.md spacing rules).
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        header,
        Transform.translate(
          offset: Offset(0, -overlap),
          child: Padding(
            padding: AppSize.padding(horizontal: AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < children.length; i++) ...<Widget>[
                  if (i > 0)
                    SizedBox(height: AppSize.getHeight(gap)),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
