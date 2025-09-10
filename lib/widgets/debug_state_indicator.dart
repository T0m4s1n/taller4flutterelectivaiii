import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/background_controller.dart';

class DebugStateIndicator extends StatefulWidget {
  const DebugStateIndicator({super.key});

  @override
  State<DebugStateIndicator> createState() => _DebugStateIndicatorState();
}

class _DebugStateIndicatorState extends State<DebugStateIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 16,
      child: Obx(() {
        final controller = Get.find<BackgroundController>(tag: 'background');
        final state = controller.currentState.value;
        
        // Trigger animation on state change
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: controller.currentColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: controller.currentColors.first.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStateIcon(state),
                      const SizedBox(width: 8),
                      Text(
                        _getStateDisplayName(state),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStateIcon(BackgroundState state) {
    IconData iconData;
    switch (state) {
      case BackgroundState.idle:
        iconData = Icons.pause_circle_outline;
        break;
      case BackgroundState.userTyping:
        iconData = Icons.edit;
        break;
      case BackgroundState.aiTyping:
        iconData = Icons.psychology;
        break;
      case BackgroundState.messageReceived:
        iconData = Icons.message;
        break;
      case BackgroundState.error:
        iconData = Icons.error;
        break;
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Icon(
        iconData,
        key: ValueKey(state),
        color: Colors.white,
        size: 20,
      ),
    );
  }

  String _getStateDisplayName(BackgroundState state) {
    switch (state) {
      case BackgroundState.idle:
        return 'IDLE';
      case BackgroundState.userTyping:
        return 'TYPING';
      case BackgroundState.aiTyping:
        return 'AI THINKING';
      case BackgroundState.messageReceived:
        return 'MESSAGE';
      case BackgroundState.error:
        return 'ERROR';
    }
  }
}
