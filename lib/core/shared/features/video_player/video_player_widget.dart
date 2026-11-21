import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:absher_park/core/shared/features/video_player/controllers/video_player_cubit.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import 'controllers/video_player_state.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({super.key, required this.file});
  final File file;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoPlayerCubit()..initFileVideo(file),
      child: BlocBuilder<VideoPlayerCubit, VideoPlayerStates>(
        // Every state after the first moves the frame or the progress bar.
        buildWhen: (previous, current) => current is! IntroInitial,
        builder: (context, state) {
          final cubit = VideoPlayerCubit.get(context);
          return Stack(
            clipBehavior: Clip.none,
            fit: StackFit.passthrough,
            children: [
              SizedBox(
                width: AppSize.getWidth(100),
                height: AppSize.getHeight(120),
                child: (cubit.controller.value.isInitialized)
                    ? VideoPlayer(cubit.controller)
                    : null,
              ),
              Positioned(
                bottom: AppSize.getHeight(20),
                right: AppSize.getWidth(20),
                child: StreamBuilder<Duration?>(
                  stream: cubit.controller.position.asStream(),
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Text(
                      "${position.inSeconds}s",
                      style: TextStyle(
                        fontSize: AppSize.font(12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    );
                  },
                ),
                // Text(
                //   "${cubit.controller.value.position.inSeconds} S",
                //   style: TextStyle(
                //     fontSize: AppSize.font(12),
                //     fontWeight: FontWeight.w700,
                //     color: AppColors.white,
                //   ),
                // )
              ),
              if (state is Loading)
                Positioned(
                  bottom: AppSize.getHeight(60),
                  right: AppSize.getWidth(50),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class NetworkVideoPlayer extends StatelessWidget {
  const NetworkVideoPlayer({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.volume,
    this.stackHeight,
    this.stackWidth,
  });
  final String url;
  final double? width;
  final double? height;
  final double? volume;
  final double? stackHeight;
  final double? stackWidth;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoPlayerCubit()..initNetworkVideo(url, volume ?? 0),
      child: BlocBuilder<VideoPlayerCubit, VideoPlayerStates>(
        // Every state after the first moves the frame or the progress bar.
        buildWhen: (previous, current) => current is! IntroInitial,
        builder: (context, state) {
          final cubit = VideoPlayerCubit.get(context);
          return Stack(
            clipBehavior: Clip.none,
            fit: StackFit.passthrough,
            children: [
              SizedBox(
                width: width ?? AppSize.getWidth(100),
                height: height ?? AppSize.getHeight(120),
                child: (cubit.controller.value.isInitialized)
                    ? VideoPlayer(cubit.controller)
                    : null,
              ),
              Positioned(
                bottom: AppSize.getHeight(20),
                right: AppSize.getWidth(20),
                child: StreamBuilder<Duration?>(
                  stream: cubit.controller.position.asStream(),
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Text(
                      "${position.inSeconds}s",
                      style: TextStyle(
                        fontSize: AppSize.font(12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    );
                  },
                ),
                // Text(
                //   "${cubit.controller.value.position.inSeconds} S",
                //   style: TextStyle(
                //     fontSize: AppSize.font(12),
                //     fontWeight: FontWeight.w700,
                //     color: AppColors.white,
                //   ),
                // )
              ),
              if (state is Loading)
                Positioned(
                  bottom: stackHeight ?? AppSize.getHeight(60),
                  right: stackWidth ?? AppSize.getWidth(50),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
