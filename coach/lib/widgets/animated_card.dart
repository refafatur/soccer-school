import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedTigerCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedTigerCard({
    required this.child,
    this.onTap,
  });

  @override
  State<AnimatedTigerCard> createState() => _AnimatedTigerCardState();
}

class _AnimatedTigerCardState extends State<AnimatedTigerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -5.0 : 0.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(_isHovered ? 0.15 : 0.1),
              Colors.white.withOpacity(_isHovered ? 0.1 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.tigerOrange.withOpacity(_isHovered ? 0.5 : 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.tigerOrange.withOpacity(_isHovered ? 0.2 : 0.1),
              blurRadius: _isHovered ? 20 : 10,
              spreadRadius: _isHovered ? 2 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: widget.child,
          ),
        ),
      ),
    );
  }
} 