// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import '../../app/localization/app_language.dart';

const ink = Color(0xff17233a);
const muted = Color(0xff68758b);
const blue = Color(0xff2869f0);
const line = Color(0xffdce5ef);
const canvas = Color(0xfff2f5fa);

class StatusPill extends StatelessWidget {
  final String label;
  const StatusPill(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    final state = ['Published', 'Awaiting marking', 'Draft']
        .firstWhere(label.contains, orElse: () => label);
    final color = switch (state) {
      'Active' ||
      'Published' ||
      'Present' ||
      'Resolved' =>
        const Color(0xff16804b),
      'Pending review' ||
      'Draft' ||
      'In review' ||
      'Late' =>
        const Color(0xff9a6500),
      'Absent' || 'Open' => const Color(0xffbe3346),
      _ => muted
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(20)),
      child: LText(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class DashboardPanel extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;
  const DashboardPanel(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.child,
      this.action,
      this.onAction});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: line),
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
            padding: const EdgeInsets.all(22),
            child: SizedBox(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  LText(title,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: ink)),
                                  const SizedBox(height: 5),
                                  LText(subtitle,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: muted,
                                          height: 1.5)),
                                ])),
                            if (action != null)
                              TextButton(
                                  onPressed: onAction,
                                  child: LText(action!,
                                      style: const TextStyle(fontSize: 12))),
                          ]),
                      const SizedBox(height: 20),
                      child,
                    ]))),
      );
}

class DashboardColumns extends StatelessWidget {
  final Widget left, right;
  final int leftFlex, rightFlex;
  const DashboardColumns(
      {super.key,
      required this.left,
      required this.right,
      this.leftFlex = 1,
      this.rightFlex = 1});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, box) => box.maxWidth < 780
          ? Column(children: [left, const SizedBox(height: 18), right])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: leftFlex, child: left),
              const SizedBox(width: 18),
              Expanded(flex: rightFlex, child: right)
            ]));
}

class MetricCard extends StatelessWidget {
  final String title, value, note;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const MetricCard(
      {super.key,
      required this.title,
      required this.value,
      required this.note,
      required this.icon,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: .09),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(icon, color: color, size: 21)),
                      const Spacer(),
                      const Icon(Icons.north_east,
                          color: Color(0xffa0aec0), size: 16)
                    ]),
                    const SizedBox(height: 14),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            color: ink)),
                    const SizedBox(height: 7),
                    LText(title,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ink)),
                    const SizedBox(height: 5),
                    LText(note,
                        style: const TextStyle(
                            fontSize: 11, color: muted, height: 1.4)),
                  ]),
            )),
      );
}

class EmptyPanel extends StatelessWidget {
  final String title, message;
  final IconData icon;
  const EmptyPanel(this.title, this.message,
      {super.key, this.icon = Icons.inbox_outlined});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Center(
          child: Column(children: [
        Icon(icon, color: const Color(0xff8da7cc), size: 32),
        const SizedBox(height: 12),
        LText(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        LText(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12, height: 1.6)),
      ])));
}

/// One short entrance transition; respects reduced-motion preferences.
class DashboardReveal extends StatelessWidget {
  final Widget child;
  const DashboardReveal({super.key, required this.child});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(
            begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)), child: child)),
        child: child,
      );
}
