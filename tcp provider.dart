import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/init_data.dart';
import '../service/tcp_service.dart';

/// TCP接続状態プロバイダー
final tcpConnectionStateProvider =
    StateProvider<TcpConnectionState>((ref) => TcpConnectionState.disconnected);

/// 初期化データプロバイダー
final initDataProvider = StateProvider<InitData?>((ref) => null);

/// TCPサービスプロバイダー
final tcpServiceProvider = Provider<TcpService>((ref) => TcpService());
