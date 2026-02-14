import 'package:flutter/material.dart';

enum MascotState { idle, success, hint }

class MascotReactor extends StatefulWidget {
  final MascotState state;
  final double size;

  const MascotReactor({
    super.key,
    required this.state,
    this.size = 120,
  });

  @override
  State<MascotReactor> createState() => _MascotReactorState();
}

class _MascotReactorState extends State<MascotReactor> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Idle Hover Animation (Breathing/Floating effect)
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Faster
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(begin: -10.0, end: 10.0).animate( // Stronger movement
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    // Success Pop/Scale Animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(MascotReactor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == MascotState.success && oldWidget.state != MascotState.success) {
      _scaleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _getAssetForState(MascotState state) {
    switch (state) {
      case MascotState.idle:
        return 'assets/mascot/volt_idle.png';
      case MascotState.success:
        return 'assets/mascot/volt_success.png';
      case MascotState.hint:
        return 'assets/mascot/volt_hint.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _scaleController]),
      builder: (context, child) {
        // Calculate breathing scale for idle state
        // _hoverController goes 0..1..0. We map this to 1.0 .. 1.05
        final breathingScale = 1.0 + (_hoverController.value * 0.05);

        return Transform.translate(
          offset: Offset(0, _hoverAnimation.value),
          child: Transform.scale(
            scale: widget.state == MascotState.success 
                ? _scaleAnimation.value 
                : breathingScale, 
            child: child,
          ),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Image.asset(
          _getAssetForState(widget.state),
          key: ValueKey<MascotState>(widget.state),
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}
