// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import '../../app/localization/app_language.dart';
import '../../data/teacher_repository.dart';
import 'teacher_components.dart';
import 'staff_components.dart';

/// Adapts OG Vibes Staff's academic sidebar, profile toolbar and mobile navigation.
class TeacherShell extends StatefulWidget {
  final String page;
  final Map<String, String> navigation;
  final IconData Function(String) icon;
  final ValueChanged<String> navigate;
  final LocalTeacherRepository repository;
  final Widget child;
  const TeacherShell(
      {super.key,
      required this.page,
      required this.navigation,
      required this.icon,
      required this.navigate,
      required this.repository,
      required this.child});
  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  final shell = GlobalKey<ScaffoldState>();
  String get page => widget.page;
  Map<String, String> get navigation => widget.navigation;
  IconData Function(String) get icon => widget.icon;
  ValueChanged<String> get navigate => widget.navigate;
  LocalTeacherRepository get repository => widget.repository;
  Widget get child => widget.child;
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final roomy = MediaQuery.sizeOf(context).width >= 1200 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.2;
    final groups = {'TEACHING WORKSPACE': navigation.keys.toList()};
    final initials =
        repository.teacher.name.split(' ').map((s) => s[0]).take(2).join();
    Widget menu() => Material(
        color: Colors.white,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 16, 18),
              child: Row(children: [
                Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: blue, borderRadius: BorderRadius.circular(13)),
                    alignment: Alignment.center,
                    child: const Text('LD',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Lucky Dube',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: ink)),
                      const SizedBox(height: 4),
                      const LText('TEACHERS',
                          style: TextStyle(
                              color: blue,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2))
                    ])),
                if (!wide)
                  IconButton(
                      tooltip: tr(context, 'Close navigation'),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20)),
              ])),
          const Divider(height: 1),
          Expanded(
              child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  children: [
                for (final group in groups.entries) ...[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 12, 8),
                      child: LText(group.key,
                          style: const TextStyle(
                              fontSize: 9,
                              color: muted,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w700))),
                  for (final key in group.value)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: ListTile(
                            dense: true,
                            minVerticalPadding: 12,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            selected: page == key,
                            selectedTileColor: const Color(0xffeaf1ff),
                            selectedColor: blue,
                            iconColor: const Color(0xff718198),
                            textColor: const Color(0xff52627b),
                            leading: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                    color: page == key
                                        ? const Color(0xffdceaff)
                                        : const Color(0xfff0f5fb),
                                    borderRadius: BorderRadius.circular(9)),
                                child: Icon(icon(key), size: 18)),
                            title: LText(navigation[key]!,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: page == key
                                        ? FontWeight.w800
                                        : FontWeight.w600)),
                            trailing: page == key
                                ? const Icon(Icons.chevron_right, size: 16)
                                : null,
                            onTap: () {
                              if (!wide) Navigator.pop(context);
                              navigate(key);
                            })),
                ],
              ])),
          const Divider(height: 1),
          Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                    dense: true,
                    leading: CircleAvatar(
                        radius: 17,
                        backgroundColor: Color(0xffe5efff),
                        child: Text(initials,
                            style: TextStyle(
                                color: blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w800))),
                    title: Text(repository.teacher.name,
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                    subtitle: LText(repository.teacher.subject,
                        style: TextStyle(fontSize: 10, color: muted)),
                    onTap: () {
                      if (!wide) Navigator.pop(context);
                      navigate('settings');
                    }),
                TextButton.icon(
                    onPressed: repository.signOut,
                    style: TextButton.styleFrom(
                        foregroundColor: muted,
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size(double.infinity, 44)),
                    icon: const Icon(Icons.logout, size: 17),
                    label: const LText('Sign out',
                        style: TextStyle(fontSize: 11))),
              ])),
        ]));
    Widget topbar() => Container(
        height: 72,
        padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 8),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: line))),
        child: Row(children: [
          if (!wide)
            IconButton(
                tooltip: tr(context, 'Open navigation'),
                icon: const Icon(Icons.menu),
                onPressed: () => shell.currentState!.openDrawer()),
          if (roomy) ...[
            LText(repository.teacher.subject,
                style: TextStyle(color: muted, fontSize: 12)),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('/', style: TextStyle(color: Color(0xffc3ccda))))
          ],
          Expanded(
              child: LText(navigation[page] ?? 'Search workspace',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13))),
          if (roomy)
            OutlinedButton.icon(
                onPressed: () => navigate('search'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: muted,
                    minimumSize: const Size(220, 42),
                    backgroundColor: const Color(0xfff8fafd)),
                icon: const Icon(Icons.search, size: 18),
                label: const LText('Search workspace',
                    style: TextStyle(fontSize: 12)))
          else
            IconButton(
                tooltip: tr(context, 'Search workspace'),
                onPressed: () => navigate('search'),
                icon: const Icon(Icons.search)),
          const SizedBox(width: 8),
          const TeacherLanguage(),
          if (roomy) ...[
            const SizedBox(width: 12),
            InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => navigate('settings'),
                child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xffedf3ff),
                    child: Text(initials,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: blue))))
          ],
        ]));
    return Scaffold(
        key: shell,
        drawer:
            wide ? null : Drawer(width: 280, child: SafeArea(child: menu())),
        body: SafeArea(
            child: Row(children: [
          if (wide)
            Container(
                width: 248,
                decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: line))),
                child: menu()),
          Expanded(
              child: Column(children: [
            topbar(),
            Expanded(
                child: ListView(
                    padding: EdgeInsets.all(wide ? 28 : 16),
                    children: [
                  Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1440),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                child,
                                const SizedBox(height: 30),
                                const Divider(),
                                const SizedBox(height: 12),
                                const LText(
                                    'Optimal Growth Technologies SA • Changes are saved on this device. This workspace is not connected to school services.',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: muted,
                                        height: 1.7)),
                              ])))
                ]))
          ])),
        ])),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: ['home', 'resources', 'assignments', 'messages']
                        .contains(page)
                    ? ['home', 'resources', 'assignments', 'messages']
                        .indexOf(page)
                    : 4,
                onDestinationSelected: (i) {
                  if (i == 4) {
                    shell.currentState!.openDrawer();
                  } else {
                    navigate(
                        ['home', 'resources', 'assignments', 'messages'][i]);
                  }
                },
                destinations: [
                    for (final key in [
                      'home',
                      'resources',
                      'assignments',
                      'messages',
                      'more'
                    ])
                      NavigationDestination(
                          icon: Icon(key == 'more' ? Icons.menu : icon(key)),
                          label: tr(context,
                              key == 'more' ? 'More' : navigation[key]!))
                  ]));
  }
}
