import 'dart:async';
import 'dart:developer';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import '../local/cache/cache_helper.dart';
import '../local/cache/cache_keys.dart';
import '../remote/end_points.dart';

/// One event received on a channel.
class RealtimeEvent {
  const RealtimeEvent({
    required this.channel,
    required this.name,
    required this.data,
  });

  /// The channel it arrived on.
  final String channel;

  /// The event name.
  final String name;

  /// The raw payload.
  final Map<String, dynamic> data;
}

/// The websocket client.
///
/// Laravel Reverb speaks the Pusher protocol but runs on the project's own
/// host, so the client is configured with an explicit host and port rather
/// than a Pusher cluster. `pusher_channels_flutter` cannot do this — its
/// native `init()` only accepts a cluster — which is why this uses
/// `dart_pusher_channels`.
///
/// Subscription is authorised per channel through `POST /broadcasting/auth`
/// using the bearer token, never a session cookie.
///
/// No websocket server is deployed yet. [isAvailable] reports that, and every
/// caller pairs this with an [AdaptivePoller] fallback.
class RealtimeClient {
  RealtimeClient._();

  /// The shared instance.
  static final RealtimeClient instance = RealtimeClient._();

  /// Websocket key, supplied with `--dart-define`.
  static const String wsKey = String.fromEnvironment('WS_KEY');

  /// Websocket host, supplied with `--dart-define`.
  static const String wsHost = String.fromEnvironment('WS_HOST');

  /// Websocket port.
  static const int wsPort = int.fromEnvironment('WS_PORT', defaultValue: 443);

  /// Whether the websocket connection uses TLS.
  static const bool wsUseTls = bool.fromEnvironment(
    'WS_TLS',
    defaultValue: true,
  );

  final StreamController<RealtimeEvent> _events =
      StreamController<RealtimeEvent>.broadcast();
  final Map<String, PrivateChannel> _channels = <String, PrivateChannel>{};
  final Map<String, StreamSubscription<ChannelReadEvent>> _subs =
      <String, StreamSubscription<ChannelReadEvent>>{};

  PusherChannelsClient? _client;
  StreamSubscription<void>? _connectionSub;
  bool _connected = false;

  /// Every event from every subscribed channel.
  Stream<RealtimeEvent> get events => _events.stream;

  /// Whether this build has a websocket server configured.
  ///
  /// False until one is deployed — a backend blocker the app cannot resolve.
  bool get isAvailable => wsKey.isNotEmpty && wsHost.isNotEmpty;

  /// Whether the socket is currently connected.
  bool get isConnected => _connected;

  /// Connects, if a server is configured. Safe to call more than once.
  Future<void> connect() async {
    if (!isAvailable || _client != null) return;

    final PusherChannelsClient client = PusherChannelsClient.websocket(
      options: const PusherChannelsOptions.fromHost(
        scheme: wsUseTls ? 'wss' : 'ws',
        host: wsHost,
        port: wsPort,
        key: wsKey,
      ),
      connectionErrorHandler:
          (dynamic error, StackTrace trace, void Function() refresh) {
            log('socket error: $error', name: 'realtime');
            refresh();
          },
    );

    _client = client;
    _connectionSub = client.onConnectionEstablished.listen((_) {
      _connected = true;
      for (final PrivateChannel channel in _channels.values) {
        channel.subscribeIfNotUnsubscribed();
      }
    });

    try {
      await client.connect();
    } catch (e) {
      log('socket connect failed: $e', name: 'realtime');
    }
  }

  /// Subscribes to [channelName].
  Future<void> subscribe(String channelName) async {
    final PusherChannelsClient? client = _client;
    if (!isAvailable || client == null) return;
    if (_channels.containsKey(channelName)) return;

    final String? token = CacheHelper.get(CacheKeys.token) as String?;
    if (token == null) return;

    final PrivateChannel channel = client.privateChannel(
      channelName,
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint: Uri.parse('${BASE_URL}broadcasting/auth'),
            headers: <String, String>{
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
    );

    _channels[channelName] = channel;
    _subs[channelName] = channel.bindToAll().listen((ChannelReadEvent event) {
      if (_events.isClosed) return;
      _events.add(
        RealtimeEvent(
          channel: channelName,
          name: event.name,
          data: event.tryGetDataAsMap() ?? const <String, dynamic>{},
        ),
      );
    });

    channel.subscribeIfNotUnsubscribed();
  }

  /// Unsubscribes from [channelName] and releases its listener.
  Future<void> unsubscribe(String channelName) async {
    await _subs.remove(channelName)?.cancel();
    _channels.remove(channelName)?.unsubscribe();
  }

  /// Events on [channelName] only.
  Stream<RealtimeEvent> on(String channelName) =>
      events.where((RealtimeEvent e) => e.channel == channelName);

  /// Disconnects and drops every subscription.
  Future<void> disconnect() async {
    for (final String name in _channels.keys.toList()) {
      await unsubscribe(name);
    }
    await _connectionSub?.cancel();
    _connectionSub = null;
    _client?.dispose();
    _client = null;
    _connected = false;
  }
}
