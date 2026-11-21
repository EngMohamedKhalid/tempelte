import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import '../../style/app_tone.dart';

/// A status pill: the tone's colours, always with its label.
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.tone, required this.label, super.key})
    : _status = null;

  /// A booking's status. The seven verified words are translated through
  /// the existing `board.status.*` keys; anything else is gray with the
  /// server's own word, and a blank one reads "—".
  const StatusBadge.booking(String status, {super.key})
    : _status = status,
      tone = AppTone.gray,
      label = '';

  final AppTone tone;
  final String label;
  final String? _status;

  @override
  Widget build(BuildContext context) {
    final String? status = _status;
    final AppTone t = status == null ? tone : AppTone.forBooking(status);
    final String text = status == null
        ? label
        : AppTone.isKnownBooking(status)
        ? 'board.status.${AppTone.normalise(status)}'.tr()
        : (status.trim().isEmpty ? '—' : status.trim());

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.bgOn(dark: AppColors.isDark()),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: t.ring),
      ),
      child: Padding(
        padding: AppSize.padding(horizontal: 8, vertical: 2),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: t.fgOn(dark: AppColors.isDark()),
          ),
        ),
      ),
    );
  }
}
