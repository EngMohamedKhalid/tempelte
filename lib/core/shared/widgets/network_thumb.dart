import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';

/// A square thumbnail of a remote image or video (F26 booking attachments).
///
/// Decoded at the size it is painted — `memCacheWidth` is the tile's width
/// times the device pixel ratio (flutter-skills image-memory rule), so a 12 MP
/// key photo costs a thumbnail's memory, not a photo's. A video shows a play
/// glyph over whatever frame the server sends, or over the placeholder.
class NetworkThumb extends StatelessWidget {
  const NetworkThumb({
    required this.url,
    required this.size,
    this.isVideo = false,
    this.onTap,
    super.key,
  });

  final String url;

  /// The tile's side before `AppSize` scaling.
  final double size;
  final bool isVideo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double side = AppSize.getSize(size);
    final int cache = (side * MediaQuery.devicePixelRatioOf(context)).round();
    final BorderRadius radius = BorderRadius.circular(
      AppSize.getSize(AppRadius.control),
    );
    final Widget placeholder = Container(
      color: AppColors.isDark() ? AppColors.navy800 : AppColors.navy100,
      alignment: Alignment.center,
      child: Icon(
        isVideo ? Icons.videocam_rounded : Icons.photo_rounded,
        color: AppColors.quietText,
        size: side * 0.3,
      ),
    );

    return Semantics(
      button: onTap != null,
      image: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: cache,
                  placeholder: (_, _) => placeholder,
                  errorWidget: (_, _, _) => placeholder,
                ),
                if (isVideo)
                  Center(
                    child: Container(
                      width: side * 0.36,
                      height: side * 0.36,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.navy800,
                        size: side * 0.24,
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
