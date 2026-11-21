import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';

import '../../style/app_size.dart';
import '../features/video_player/video_player_widget.dart';

class CameraAwesomePicker extends StatelessWidget {
  const CameraAwesomePicker({
    super.key,
    required this.selectedFiles,
    this.onMediaCaptureEvent,
    this.onRemove,
  });
  final List<File> selectedFiles;
  final Function(int)? onRemove;
  final Function(MediaCapture)? onMediaCaptureEvent;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: AppSize.getHeight(500),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CameraAwesomeBuilder.awesome(
              saveConfig: SaveConfig.photoAndVideo(),
              onMediaCaptureEvent: onMediaCaptureEvent,
            ),
          ),
        ),
        SizedBox(height: AppSize.getHeight(20)),
        DynamicHeightGridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: selectedFiles.length,
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          builder: (ctx, index) {
            return Stack(
              alignment: Alignment.topRight,
              clipBehavior: Clip.none,
              fit: StackFit.passthrough,
              children: [
                if (selectedFiles[index].path.endsWith('.mp4')) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: VideoPlayerWidget(file: selectedFiles[index]),
                  ),
                ] else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      width: AppSize.getWidth(100),
                      height: AppSize.getHeight(120),
                      fit: BoxFit.fill,
                      selectedFiles[index],
                    ),
                  ),
                ],
                Positioned(
                  top: AppSize.getHeight(10),
                  right: AppSize.getWidth(10),
                  child: InkWell(
                    onTap: () => onRemove!(index),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
