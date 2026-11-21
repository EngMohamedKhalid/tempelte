import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controllers/safe_emit.dart';
import 'package:absher_park/core/shared/features/video_player/controllers/video_player_state.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerStates> with SafeEmit<VideoPlayerStates> {
  VideoPlayerCubit() : super(IntroInitial());

  static VideoPlayerCubit get(BuildContext context) => BlocProvider.of(context);

  late VideoPlayerController controller;

  void initFileVideo(File file) {
    emit(Loading());
    controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        emit(Success());
        controller.play();
        controller.setLooping(false);
        controller.addListener(() {
          emit(Success());
        });
      });
  }

  void initNetworkVideo(String url, double volume) {
    emit(Loading());
    controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        emit(Success());
        controller.setVolume(volume);
        controller.play();
        controller.setLooping(false);
        controller.addListener(() {
          emit(Success());
        });
      });
  }

  void initAssetVideo(String url) {
    emit(Loading());
    controller = VideoPlayerController.asset(url)
      ..initialize().then((_) {
        emit(Success());
        controller.play();
        controller.setLooping(false);
        controller.addListener(() {
          emit(Success());
        });
      });
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}
