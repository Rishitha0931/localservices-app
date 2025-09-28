// translations.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart'; // import your provider
import 'lang_strings.dart'; // import your localizedStrings map

String tr(BuildContext context, String key) {
  final langCode =
      Provider.of<LanguageProvider>(context).currentLocale.languageCode;
  return localizedStrings[langCode]?[key] ?? key;
}
