import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notifications/presentation/controller/notifications_cubit.dart';
import '../controller/force_update_cubit.dart';
import '../controller/splash_cubit.dart';
import 'force_update_screen.dart';
import '../widgets/splash_body.dart';

/// The entry screen.
///
/// A [StatelessWidget]: the decision lives in [SplashCubit] and the update
/// gate in [ForceUpdateCubit]. The legacy splash is a `StatefulWidget` that
/// navigates from `initState` and sleeps a second on every branch.
///
/// The update check runs first, because there is no point resolving a session
/// for a build the user has to replace.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ForceUpdateCubit()..check()),
        BlocProvider(create: (_) => SplashCubit()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ForceUpdateCubit, ForceUpdateState>(
            listenWhen: (previous, current) => previous != current,
            listener: (context, state) {
              // The update gate is the one place a listener is the right tool:
              // it hands off to a different cubit rather than making a
              // decision.
              if (state is ForceUpdateNotRequired) {
                SplashCubit.get(context).resolve();
              }
            },
          ),
          BlocListener<SplashCubit, SplashState>(
            listenWhen: (previous, current) => previous != current,
            listener: (context, state) {
              // The session is settled and a screen is on the stack: register
              // this device, and open whatever notification launched the app.
              if (state is SplashResolved) {
                NotificationsCubit.get(context).onSessionReady();
              }
            },
          ),
        ],
        child: BlocBuilder<ForceUpdateCubit, ForceUpdateState>(
          // Only the update wall changes what is drawn.
          buildWhen: (previous, current) =>
              (previous is ForceUpdateRequired) != (current is ForceUpdateRequired),
          builder: (context, state) {
            if (state is ForceUpdateRequired) {
              return ForceUpdateScreen(
                storeVersion: state.storeVersion,
                installedVersion: state.installedVersion,
              );
            }
            return const SplashBody();
          },
        ),
      ),
    );
  }
}
