import '../../app/localization/app_language.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

const learnerAccents = [
  Color(0xff2563eb),
  Color(0xff0d9488),
  Color(0xffe76a45),
  Color(0xff8055d9)
];

/// Short entrance motion, with no recurring ticker or network assets.
class WelcomeBanner extends StatelessWidget {
  final VoidCallback onContinue;
  const WelcomeBanner({super.key, required this.onContinue});
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      duration: reduced ? Duration.zero : const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)), child: child)),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xffeaf3ff)
                  : const Color(0xff183454),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xffc9dfff))),
          child: LayoutBuilder(builder: (context, size) {
            final copy =
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const LText('PLAN • INSPIRE • SUPPORT',
                  style: TextStyle(
                      color: Color(0xff2563eb),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2)),
              const SizedBox(height: 16),
              LText('Great teaching.\nBrighter futures.',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.w800, height: 1.15)),
              const SizedBox(height: 14),
              const LText(
                  'Your lessons, your classes, your next great idea.\nMake space for every learner to grow.',
                  style: TextStyle(height: 1.6)),
              const SizedBox(height: 22),
              FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const LText('Plan your next lesson')),
            ]);
            if (size.maxWidth < 600) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    const SizedBox(height: 12),
                    const SizedBox(
                        height: 150,
                        child: Center(child: LearningIllustration()))
                  ]);
            }
            return Row(children: [
              Expanded(flex: 3, child: copy),
              const Expanded(
                  flex: 2,
                  child: SizedBox(height: 250, child: LearningIllustration()))
            ]);
          })),
    );
  }
}

/// Original layered vector artwork; rendered locally and inexpensive to paint.
class LearningIllustration extends StatefulWidget {
  const LearningIllustration({super.key});
  @override
  State<LearningIllustration> createState() => _LearningIllustrationState();
}

class _LearningIllustrationState extends State<LearningIllustration> {
  bool hover = false;
  @override
  Widget build(BuildContext context) => Semantics(
      label: tr(context,
          'An illustrated stack of colourful books with a creative spark'),
      image: true,
      child: MouseRegion(
          onEnter: (_) => setState(() => hover = true),
          onExit: (_) => setState(() => hover = false),
          child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..translateByDouble(0.0, hover ? -6.0 : 0.0, 0.0, 1.0)
                ..rotateZ(hover ? -.025 : 0),
              transformAlignment: Alignment.center,
              child: AspectRatio(
                  aspectRatio: 1.45,
                  child: CustomPaint(painter: _BooksPainter())))));
}

class _BooksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 320, size.height / 220);
    final p = Paint();
    canvas.drawOval(const Rect.fromLTWH(50, 190, 230, 16),
        p..color = const Color(0xffceddf4));
    canvas.drawCircle(
        const Offset(166, 109), 92, p..color = const Color(0xffdceaff));
    void book(double x, double y, double width, Color colour) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 5, y + 7, width, 35), const Radius.circular(9)),
          p..color = colour.withValues(alpha: .22));
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, width, 35), const Radius.circular(9)),
          p..color = colour);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x + 20, y + 5, width - 23, 24),
              const Radius.circular(5)),
          p..color = const Color(0xfffffdf6));
      canvas.drawLine(
          Offset(x + 28, y + 13),
          Offset(x + width - 12, y + 13),
          p
            ..color = const Color(0xffd9dce5)
            ..strokeWidth = 2);
      canvas.drawLine(
          Offset(x + 28, y + 20), Offset(x + width - 12, y + 20), p);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 45, y + 5, 14, 40), const Radius.circular(2)),
          p..color = const Color(0xffffbe55));
    }

    book(70, 154, 198, const Color(0xff0d9488));
    book(50, 115, 188, const Color(0xff8055d9));
    book(77, 76, 180, const Color(0xff4b8af2));
    canvas.drawCircle(
        const Offset(253, 42), 27, p..color = const Color(0xffffd884));
    canvas.drawCircle(
        const Offset(253, 42), 16, p..color = const Color(0xfffff6d8));
    final star = Path()
      ..moveTo(48, 35)
      ..lineTo(53, 48)
      ..lineTo(66, 53)
      ..lineTo(53, 58)
      ..lineTo(48, 71)
      ..lineTo(43, 58)
      ..lineTo(30, 53)
      ..lineTo(43, 48)
      ..close();
    canvas.drawPath(star, p..color = const Color(0xfff08c71));
    canvas.drawCircle(
        const Offset(286, 118), 6, p..color = const Color(0xff9ccabf));
    canvas.drawCircle(
        const Offset(107, 40), 4, p..color = const Color(0xff8055d9));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
