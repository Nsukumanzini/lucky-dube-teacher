// ignore: deprecated_member_use
import 'dart:ui' as ui;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// One app-wide backdrop makes grouped glass effects efficient on mobile GPUs.
class LiquidGlassBackdrop extends StatelessWidget {
  final bool dark;
  const LiquidGlassBackdrop({super.key, required this.dark});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _LiquidBackdropPainter(dark: dark),
        child: const SizedBox.expand(),
      );
}

class _LiquidBackdropPainter extends CustomPainter {
  final bool dark;
  const _LiquidBackdropPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        dark
            ? const [Color(0xff101729), Color(0xff111d35), Color(0xff102b32)]
            : const [Color(0xfff9fbff), Color(0xffeff5ff), Color(0xffeef9f7)],
        const [0, .56, 1],
      );
    canvas.drawRect(rect, base);
    void orb(Offset center, double radius, Color color) {
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [color, color.withValues(alpha: 0)],
          const [0, 1],
        );
      canvas.drawCircle(center, radius, paint);
    }

    if (dark) {
      orb(Offset(size.width * .08, size.height * .14), size.width * .72,
          const Color(0x442d56c7));
      orb(Offset(size.width * .95, size.height * .48), size.width * .68,
          const Color(0x3325aa9e));
      orb(Offset(size.width * .3, size.height * .98), size.width * .64,
          const Color(0x223f56c6));
    } else {
      orb(Offset(size.width * .03, size.height * .08), size.width * .9,
          const Color(0x2d7ea5ff));
      orb(Offset(size.width * .98, size.height * .37), size.width * .74,
          const Color(0x2b53d3c0));
      orb(Offset(size.width * .32, size.height * .99), size.width * .68,
          const Color(0x22aa9dff));
    }
  }

  @override
  bool shouldRepaint(_LiquidBackdropPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

/// Reusable liquid-glass surface with grouped blur, reflected highlights,
/// translucent tint, rounded hairline and soft depth.
class LiquidGlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Color? tint;
  final double blur;
  final bool edgeHighlight;
  final double? width;
  final double? height;

  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.tint,
    this.blur = 16,
    this.edgeHighlight = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color:
            tint ?? (dark ? const Color(0xc91a2740) : const Color(0xcfffffff)),
        borderRadius: borderRadius,
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .17)
              : Colors.white.withValues(alpha: .92),
          width: 1.15,
        ),
        boxShadow: dark
            ? const [
                BoxShadow(
                  color: Color(0x30030a19),
                  blurRadius: 24,
                  offset: Offset(0, 9),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x1a314b79),
                  blurRadius: 24,
                  offset: Offset(0, 9),
                ),
              ],
      ),
      child: Stack(
        children: [
          if (edgeHighlight)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: dark
                          ? [
                              Colors.white.withValues(alpha: .09),
                              Colors.white.withValues(alpha: .015),
                              const Color(0x183ba6be),
                            ]
                          : [
                              Colors.white.withValues(alpha: .5),
                              Colors.white.withValues(alpha: .05),
                              const Color(0x183d72d9),
                            ],
                    ),
                  ),
                ),
              ),
            ),
          Material(
            type: MaterialType.transparency,
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: blur <= 0
            ? surface
            : BackdropFilter.grouped(
                filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: surface,
              ),
      ),
    );
  }
}

/// Kept as a source-compatible alias for older feature screens.
typedef FrostedSurface = LiquidGlassSurface;

/// Background used by top bars and bottom action docks.
class LiquidGlassBar extends StatelessWidget {
  const LiquidGlassBar({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LiquidGlassSurface(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      blur: 22,
      tint: dark ? const Color(0xc9142038) : const Color(0xc7ffffff),
      child: const SizedBox.expand(),
    );
  }
}

/// Compact entrance used when a destination changes. Respects reduced motion.
class PageReveal extends StatelessWidget {
  final Widget child;
  const PageReveal({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? 1 : 0, end: 1),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, reduce ? 0 : 12 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Material icon badge with a short scale-in entrance.
class AnimatedIconBadge extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color? background;
  final double size;
  const AnimatedIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.background,
    this.size = 44,
  });

  @override
  State<AnimatedIconBadge> createState() => _AnimatedIconBadgeState();
}

class _AnimatedIconBadgeState extends State<AnimatedIconBadge> {
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? 1 : .82, end: 1),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.background ?? widget.color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(widget.size * .32),
        ),
        alignment: Alignment.center,
        child: Icon(widget.icon, color: widget.color, size: widget.size * .5),
      ),
    );
  }
}
