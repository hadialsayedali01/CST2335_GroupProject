import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A helper class for managing localized strings loaded from JSON assets.
///
/// This class handles loading the correct language file based on the user's [Locale]
/// and provides a method to retrieve translated strings.
class AppLocalizations {
  /// The current locale of the application (e.g., 'en', 'es').
  final Locale locale;

  /// Stores the key-value pairs of localized strings.
  late Map<String, String> _localizedStrings;

  /// Creates a new [AppLocalizations] instance for the specific [locale].
  AppLocalizations(this.locale) {
    _localizedStrings = <String, String>{};
  }

  /// Helper method to retrieve the [AppLocalizations] instance from the widget tree.
  ///
  /// Usage: `AppLocalizations.of(context)?.translate('my_key')`
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// The delegate instance used to configure [Localizations] in the [MaterialApp].
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Loads the JSON language file from the 'assets/translations' directory.
  ///
  /// The file name must match the language code (e.g., 'en.json', 'fr.json').
  Future<void> load() async {
    // Load the JSON string from the asset bundle
    String jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );

    // Decode the JSON and map it to the _localizedStrings map
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  /// Retrieves a localized string by its [key].
  ///
  /// Returns `null` if the key is not found.
  String? translate(String key) {
    return _localizedStrings[key];
  }
}

/// A custom [LocalizationsDelegate] that facilitates loading [AppLocalizations].
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /// Checks if the selected [locale] is supported.
  ///
  /// Currently returns `true` for all locales. In a production app, you might
  /// want to check against a specific list of supported language codes.
  @override
  bool isSupported(Locale locale) {
    return true;
  }

  /// Loads the [AppLocalizations] class and triggers the JSON loading process.
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  /// Returns `false` because the localization logic does not need to rebuild unnecessarily.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
