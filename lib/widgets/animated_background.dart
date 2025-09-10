import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/background_controller.dart';
import 'theme_pattern_painter.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late BackgroundController backgroundController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rippleController;
  late AnimationController _shakeController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Get background controller
    backgroundController = Get.find<BackgroundController>(tag: 'background');
    
    // Initialize animation controller in background controller
    backgroundController.animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    backgroundController.animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: backgroundController.animationController!, curve: Curves.easeInOut),
    );
    backgroundController.animationController!.repeat(reverse: true);
    
    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize animations
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _rippleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startAnimation(BackgroundState state) {
    // Stop all animations
    _pulseController.stop();
    _waveController.stop();
    _rippleController.stop();
    _shakeController.stop();

    // Start appropriate animation
    switch (state) {
      case BackgroundState.idle:
        // No animation for idle state
        break;
      case BackgroundState.userTyping:
        _pulseController.repeat(reverse: true);
        break;
      case BackgroundState.aiTyping:
        _waveController.repeat();
        break;
      case BackgroundState.messageReceived:
        _rippleController.forward().then((_) => _rippleController.reset());
        break;
      case BackgroundState.error:
        _shakeController.repeat(reverse: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = backgroundController.currentState.value;
      _startAnimation(state);
      
      return AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _waveAnimation,
          _rippleAnimation,
          _shakeAnimation,
        ]),
        builder: (context, child) {
          return AnimatedContainer(
            duration: backgroundController.getAnimationDuration(),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: backgroundController.currentColors,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                _buildBackgroundPattern(state),
                // State transition overlay
                _buildStateTransitionOverlay(state),
                // Main content
                widget.child,
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildBackgroundPattern(BackgroundState state) {
    // Get theme-specific pattern
    final themePattern = backgroundController.currentThemePattern;
    
    // Override with state-specific patterns for certain states
    if (state == BackgroundState.userTyping) {
      return _buildPulsePattern();
    } else if (state == BackgroundState.aiTyping) {
      return _buildWavePattern();
    } else if (state == BackgroundState.messageReceived) {
      return _buildRipplePattern();
    } else if (state == BackgroundState.error) {
      return _buildShakePattern();
    } else {
      // Use theme-specific pattern for idle state
      return _buildThemePattern(themePattern);
    }
  }

  Widget _buildThemePattern(String patternType) {
    return CustomPaint(
      painter: ThemePatternPainter(
        patternType: patternType,
        animationValue: _waveAnimation.value,
        colors: backgroundController.currentColors,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildStateTransitionOverlay(BackgroundState state) {
    return AnimatedOpacity(
      opacity: backgroundController.getOpacity(),
      duration: backgroundController.getAnimationDuration(),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPulsePattern() {
    final intensity = backgroundController.getAnimationIntensity();
    return Transform.scale(
      scale: _pulseAnimation.value * intensity,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.white.withOpacity(0.4 * _pulseAnimation.value),
              Colors.cyan.withOpacity(0.2 * _pulseAnimation.value),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWavePattern() {
    final intensity = backgroundController.getAnimationIntensity();
    return Transform.scale(
      scale: 1.0 + (0.2 * _waveAnimation.value * intensity),
      child: CustomPaint(
        painter: WavePainter(_waveAnimation.value * intensity),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildRipplePattern() {
    final intensity = backgroundController.getAnimationIntensity();
    return Center(
      child: Stack(
        children: List.generate(3, (index) {
          final delay = index * 0.3;
          final animationValue = (_rippleAnimation.value - delay).clamp(0.0, 1.0);
          return Transform.scale(
            scale: animationValue * intensity,
            child: Container(
              width: 300 + (index * 100),
              height: 300 + (index * 100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.6 * (1 - animationValue)),
                  width: (3 + index).toDouble(),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShakePattern() {
    final intensity = backgroundController.getAnimationIntensity();
    return Transform.translate(
      offset: Offset(_shakeAnimation.value * intensity, _shakeAnimation.value * 0.5),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.withOpacity(0.3),
              Colors.orange.withOpacity(0.3),
              Colors.yellow.withOpacity(0.2),
            ],
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 40.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.5 +
          waveHeight * 
          sin(animationValue * 2 * pi + x / waveLength) *
          (1 + 0.5 * sin(animationValue * 4 * pi + x / waveLength));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
