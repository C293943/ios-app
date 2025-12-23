import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

enum RitualType { lantern, jade }

class RitualButton extends StatefulWidget {
  final String label;
  final RitualType type;
  final VoidCallback onTap;

  const RitualButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
  });

  @override
  State<RitualButton> createState() => _RitualButtonState();
}

class _RitualButtonState extends State<RitualButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathe = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* 
     * Design: 
     * Vertical text below a hanging icon (Lantern or Jade).
     * The icon bobs gently.
     */
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _breathe,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathe.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: widget.type == RitualType.lantern ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: widget.type == RitualType.lantern ? BorderRadius.circular(8) : null,
                    color: Colors.black26,
                    border: Border.all(
                      color: AppTheme.moonHalo.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.type == RitualType.lantern 
                            ? Colors.orange.withOpacity(0.2)
                            : AppTheme.spiritJade.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.type == RitualType.lantern 
                        ? Icons.light_mode_outlined // Placeholder for Lantern
                        : Icons.spa_outlined,       // Placeholder for Jade/Knot
                    color: AppTheme.moonHalo,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Vertical Text (Simulated by 1 char per line if needed, but here just styled text)
          Text(
            widget.label,
            style: TextStyle(
              color: AppTheme.moonHalo.withOpacity(0.9),
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
