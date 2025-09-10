import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/background_controller.dart';

class StateTestControls extends StatelessWidget {
  const StateTestControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: () => _showStateMenu(context),
            child: const Icon(Icons.tune),
            backgroundColor: Colors.black.withOpacity(0.7),
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 8),
          Obx(() {
            final controller = Get.find<BackgroundController>(tag: 'background');
            return FloatingActionButton(
              mini: true,
              onPressed: () {
                // Cycle through states
                final currentState = controller.currentState.value;
                BackgroundState nextState;
                switch (currentState) {
                  case BackgroundState.idle:
                    nextState = BackgroundState.userTyping;
                    break;
                  case BackgroundState.userTyping:
                    nextState = BackgroundState.aiTyping;
                    break;
                  case BackgroundState.aiTyping:
                    nextState = BackgroundState.messageReceived;
                    break;
                  case BackgroundState.messageReceived:
                    nextState = BackgroundState.error;
                    break;
                  case BackgroundState.error:
                    nextState = BackgroundState.idle;
                    break;
                }
                controller.changeState(nextState);
              },
              child: const Icon(Icons.skip_next),
              backgroundColor: controller.currentColors.first,
              foregroundColor: Colors.white,
            );
          }),
        ],
      ),
    );
  }

  void _showStateMenu(BuildContext context) {
    final controller = Get.find<BackgroundController>(tag: 'background');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Test Background States',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...BackgroundState.values.map((state) => ListTile(
              leading: Icon(
                _getStateIcon(state),
                color: controller.currentState.value == state 
                    ? controller.currentColors.first 
                    : Colors.white.withOpacity(0.7),
              ),
              title: Text(
                _getStateDisplayName(state),
                style: TextStyle(
                  color: controller.currentState.value == state 
                      ? controller.currentColors.first 
                      : Colors.white,
                  fontWeight: controller.currentState.value == state 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                controller.changeState(state);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getStateIcon(BackgroundState state) {
    switch (state) {
      case BackgroundState.idle:
        return Icons.pause_circle_outline;
      case BackgroundState.userTyping:
        return Icons.edit;
      case BackgroundState.aiTyping:
        return Icons.psychology;
      case BackgroundState.messageReceived:
        return Icons.message;
      case BackgroundState.error:
        return Icons.error;
    }
  }

  String _getStateDisplayName(BackgroundState state) {
    switch (state) {
      case BackgroundState.idle:
        return 'Idle State';
      case BackgroundState.userTyping:
        return 'User Typing';
      case BackgroundState.aiTyping:
        return 'AI Thinking';
      case BackgroundState.messageReceived:
        return 'Message Received';
      case BackgroundState.error:
        return 'Error State';
    }
  }
}

