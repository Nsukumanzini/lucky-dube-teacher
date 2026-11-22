import '../../app/localization/app_language.dart';
// Keep compatibility with Flutter versions before the Material package split.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A full route with responsive reading width and keyboard-safe action area.
class FeaturePage extends StatelessWidget {
  final Widget title, content;
  final List<Widget> actions;
  final bool scrollable;
  const FeaturePage(
      {super.key,
      required this.title,
      required this.content,
      this.actions = const [],
      this.scrollable = true});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: title,
            leading: BackButton(onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/home');
              }
            })),
        body: SafeArea(
            child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.sizeOf(context).width < 600 ? 20 : 32),
                        child: scrollable
                            ? SingleChildScrollView(
                                child: SizedBox(
                                    width: double.infinity, child: content))
                            : content)))),
        bottomNavigationBar: actions.isEmpty
            ? null
            : SafeArea(
                top: false,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                            top: BorderSide(
                                color: Theme.of(context).dividerColor))),
                    child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 8,
                        children: actions))),
      );
}

class EntryScreen extends StatefulWidget {
  final String title, hint;
  const EntryScreen({super.key, required this.title, required this.hint});
  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final controller = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FeaturePage(
          title: LText(widget.title),
          content: Form(
              key: form,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(widget.title,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    const LText(
                        'Your information is saved on this device only.'),
                    const SizedBox(height: 28),
                    TextFormField(
                        controller: controller,
                        maxLines: 6,
                        autofocus: true,
                        decoration: InputDecoration(
                            labelText: widget.hint, alignLabelWithHint: true),
                        validator: (value) => value == null ||
                                value.trim().isEmpty
                            ? tr(context, 'Please enter details before saving.')
                            : null),
                  ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const LText('Cancel')),
            FilledButton(
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(context, controller.text.trim());
                  }
                },
                child: const LText('Save'))
          ]);
}
