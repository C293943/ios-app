import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

class SpiritStage extends StatefulWidget {
  final Widget? child; // Placeholder for the 3D model
  final bool isThinking; // For "Heart Light" activation

  const SpiritStage({
    super.key, 
    this.child,
    this.isThinking = false,
  });

  @override
  State<SpiritStage> createState() => _SpiritStageState();
}

class _SpiritStageState extends State<SpiritStage> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breatheAnim;
  
  List<AnimationController> _rippleControllers = [];

  @override
  void initState() {
    super.initState();
    // Breathing Animation (Up/Down + Scale)
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _breatheAnim = Tween<double>(begin: 0.0, end: 10.0).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    for (var controller in _rippleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _triggerRipple() {
    // Limit ripples
    if (_rippleControllers.length > 5) return;

    final controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    setState(() {
      _rippleControllers.add(controller);
    });
    
    controller.forward().then((_) {
      setState(() {
        _rippleControllers.remove(controller);
      });
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerRipple,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Lotus Ripples (Interactive)
          ..._rippleControllers.map((controller) => _buildRipple(controller)),

          // 2. Main Spirit Container
          AnimatedBuilder(
            animation: _breatheAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _breatheAnim.value), // Hovering effect
                child: SizedBox(
                  height: 400,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow/Backlight (The "Moon Halo" behind spirit)
                      Container(
                        width: 280,
                        height: 380,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.isThinking 
                                  ? AppTheme.amberGold.withOpacity(0.4) 
                                  : AppTheme.fluorescentCyan.withOpacity(0.2), // Updated colors
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      
                      // The Content (3D Model / Image)
                      if (widget.child != null) 
                        widget.child!
                      else 
                        // Default Placeholder if no child provided
                        Image.asset(
                          'assets/images/spirit_placeholder.png', 
                          errorBuilder: (c, e, s) => Icon(
                            Icons.self_improvement, 
                            size: 150, 
                            color: AppTheme.fluorescentCyan.withOpacity(0.8) // Updated color
                          ),
                        ),
                        
                      // Heart Light (When thinking/processing)
                      if (widget.isThinking)
                        Positioned(
                          top: 150,
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.5, end: 1.0),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOut,
                            builder: (context, val, child) {
                              return Container(
                                width: 20 * val,
                                height: 20 * val,
                                decoration: BoxDecoration(
                                  color: AppTheme.amberGold.withOpacity(val),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.amberGold,
                                      blurRadius: 20 * val,
                                    )
                                  ],
                                ),
                              );
                            },
                            onEnd: () {}, 
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRipple(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final val = controller.value;
        return Positioned(
          bottom: 40, 
          child: Opacity(
            opacity: (1 - val) * 0.6,
            child: Container(
              width: 100 + (val * 200),
              height: 30 + (val * 60), 
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.fluorescentCyan, // Updated to Cyan
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.elliptical(50 + (val * 100), 15 + (val * 30))),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MagicCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 100); // Shifted down for perspective
    final paint = Paint()
      ..color = AppTheme.fluorescentCyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Outer Ring
    canvas.drawCircle(center, 80, paint);
    
    // Inner Ring
    canvas.drawCircle(center, 50, paint..strokeWidth = 1);
    
    // Abstract Runes/Array Lines
    for (int i = 0; i < 8; i++) {
        final angle = (i * 3.14159 / 4);
        final p1 = center + Offset(50 * 0.6 * -1 * (i % 2 == 0 ? 1 : 0), 0); // Simplified trig logic replacement
        // Just drawing some spokes for visual effect
        canvas.drawLine(
            center + Offset(50 * 0.0, 0).translate(50 * 0.1 * i, 50 * 0.1 * i), // Placeholder math
            center + Offset(80 * 0.0, 0), 
            paint
        );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
