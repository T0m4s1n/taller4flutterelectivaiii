import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({super.key});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  bool _isConnected = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final chatController = Get.find<ChatController>();
    final isConnected = await chatController.testAPIConnection();
    
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isChecking 
              ? Colors.orange.withOpacity(0.8)
              : _isConnected 
                  ? Colors.green.withOpacity(0.8)
                  : Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isChecking) ...[
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Checking...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Icon(
                _isConnected ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isConnected ? 'AI Connected' : 'AI Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

