// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'catalog.dart';

class AppLanguage {
  final Locale locale;
  const AppLanguage(this.locale);
  static AppLanguage of(BuildContext context) =>
      Localizations.of<AppLanguage>(context, AppLanguage) ??
      const AppLanguage(Locale('en', 'ZA'));
  static const delegate = _LanguageDelegate();
  String translate(String source) {
    if (locale.languageCode != 'zu') return source;
    if (isiZuluCatalog.containsKey(source)) return isiZuluCatalog[source]!;
    // Single-pass phrase substitution handles composed labels while preserving IDs,
    // names, numbers and placeholders. Repository identities always stay canonical.
    return source.replaceAllMapped(_phrases, (m) => isiZuluCatalog[m[0]]!);
  }

  static final _keys = isiZuluCatalog.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  static final _phrases = RegExp(_keys
      .map((key) =>
          '${RegExp(r"^[A-Za-z]").hasMatch(key) ? r"(?<![A-Za-z])" : ""}${RegExp.escape(key)}${RegExp(r"[A-Za-z]$").hasMatch(key) ? r"(?![A-Za-z])" : ""}')
      .join('|'));
}

class _LanguageDelegate extends LocalizationsDelegate<AppLanguage> {
  const _LanguageDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'zu'].contains(locale.languageCode);
  @override
  Future<AppLanguage> load(Locale locale) =>
      SynchronousFuture(AppLanguage(locale));
  @override
  bool shouldReload(_LanguageDelegate old) => false;
}

String tr(BuildContext context, String source) =>
    AppLanguage.of(context).translate(source);

/// Translates application-owned display text; never used as an entity identifier.
class LText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final String? semanticsLabel;
  const LText(this.data,
      {super.key,
      this.style,
      this.textAlign,
      this.overflow,
      this.maxLines,
      this.softWrap,
      this.semanticsLabel});
  @override
  Widget build(BuildContext context) => Text(tr(context, data),
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      semanticsLabel:
          semanticsLabel == null ? null : tr(context, semanticsLabel!));
}
