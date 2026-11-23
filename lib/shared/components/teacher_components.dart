// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../app/localization/app_language.dart';

class TeacherLanguage extends ConsumerWidget {
  const TeacherLanguage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(teacherRepositoryProvider);
    return PopupMenuButton<String>(
        tooltip: 'Language / Ulimi',
        onSelected: repo.setLanguage,
        itemBuilder: (_) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'zu', child: Text('isiZulu'))
            ],
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.translate, size: 19),
              const SizedBox(width: 6),
              Text(repo.language == 'zu' ? 'isiZulu' : 'English',
                  style: const TextStyle(fontSize: 12))
            ])));
  }
}

class TeacherPage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool scroll;
  const TeacherPage(
      {super.key,
      required this.title,
      required this.child,
      this.actions = const [],
      this.scroll = true});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          leading: BackButton(onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home');
            }
          }),
          title: LText(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: const [TeacherLanguage()]),
      body: SafeArea(
          child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width >= 1280
                          ? 1240
                          : 1080),
                  child: Padding(
                      padding: EdgeInsets.all(_pageGutter(context)),
                      child: scroll
                          ? SingleChildScrollView(
                              child: SizedBox(
                                  width: double.infinity, child: child))
                          : child)))),
      bottomNavigationBar: actions.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 8,
                      children: actions))));

  double _pageGutter(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 16;
    if (width < 1000) return 24;
    return 32;
  }
}

class Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const Panel(this.title, this.child, {super.key});
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
          padding: const EdgeInsets.all(22),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LText(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            child
          ])));
}

class PageHeading extends StatelessWidget {
  final String title, subtitle;
  const PageHeading(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LText(title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.6)),
        const SizedBox(height: 8),
        LText(subtitle,
            style: const TextStyle(color: Color(0xff64748b), height: 1.5))
      ]));
}

class ActionTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const ActionTile(this.title, this.subtitle, this.icon, this.onTap,
      {super.key, this.color = const Color(0xff2563eb)});
  @override
  Widget build(BuildContext context) => ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color)),
      title: LText(title),
      subtitle: LText(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap);
}

void savedMessage(BuildContext context,
        [String message = 'Saved on this device']) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: LText(message)));
Future<bool> confirmLocalReset(BuildContext context) async =>
    await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const LText('Reset local information?'),
                content: const LText(
                    'This removes your saved work on this device. Other teacher profiles are not changed.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const LText('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const LText('Reset'))
                ])) ??
    false;
