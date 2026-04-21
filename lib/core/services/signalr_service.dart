import 'dart:developer' as dev;
import 'package:signalr_netcore/signalr_client.dart';
import 'package:aisep_capstone_mobile/core/network/dio_client.dart';
import 'package:aisep_capstone_mobile/features/messages/models/chat_model.dart';
import 'package:aisep_capstone_mobile/core/config/app_config.dart';
import 'package:aisep_capstone_mobile/core/services/token_service.dart';

class SignalRService {
  HubConnection? _hubConnection;
  Function(MessageModel)? _onMessageReceived;

  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  Future<void> init(Function(MessageModel) onMessageReceived) async {
    _onMessageReceived = onMessageReceived;
    
    final token = await TokenService.getAccessToken();
    if (token == null) {
      dev.log('SignalRService: Cannot init, no token found');
      return;
    }

    final hubUrl = '${AppConfig.apiBaseUrl}/chatHub';
    
    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, options: HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ))
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          // currentUserId = 0 here because isMine logic should be handled by the JSON field 'isMine' or server logic
          final message = MessageModel.fromJson(data, 0); 
          _onMessageReceived?.call(message);
          dev.log('SignalR: New message received for conversation ${message.id}');
        } catch (e) {
          dev.log('SignalR: Error parsing received message: $e');
        }
      }
    });

    try {
      await _hubConnection?.start();
      dev.log('SignalR: Connection started successfully');
    } catch (e) {
      dev.log('SignalR: Error starting connection: $e');
    }

    _hubConnection?.onclose(({error}) {
      dev.log('SignalR: Connection closed. Error: $error');
    });
  }

  Future<void> stop() async {
    await _hubConnection?.stop();
    _hubConnection = null;
  }
}
