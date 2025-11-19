import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/blocs/bullet_journal_bloc.dart';
import 'src/providers/app_settings_provider.dart';
import 'src/router/app_router.dart';

void main() {
  runApp(const BulletJournalApp());
}

class BulletJournalApp extends StatefulWidget {
  const BulletJournalApp({super.key});

  @override
  State<BulletJournalApp> createState() => _BulletJournalAppState();
}

class _BulletJournalAppState extends State<BulletJournalApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String? _fontFamily;

  void _onThemeChanged(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _onFontFamilyChanged(String? fontFamily) {
    setState(() {
      _fontFamily = fontFamily?.isEmpty == true ? null : fontFamily;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BulletJournalBloc(),
      child: AppSettingsProvider(
        themeMode: _themeMode,
        fontFamily: _fontFamily,
        onThemeChanged: _onThemeChanged,
        onFontFamilyChanged: _onFontFamilyChanged,
        child: MaterialApp.router(
          title: 'Bullet Journal',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko', 'KR'),
            Locale('en', 'US'),
          ],
          locale: const Locale('ko', 'KR'),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
            fontFamily: _getFontFamily(_fontFamily),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: _getFontFamily(_fontFamily),
          ),
          themeMode: _themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }

  String? _getFontFamily(String? fontFamilyKey) {
    if (fontFamilyKey == null) return null;
    switch (fontFamilyKey) {
      case 'NotoSansKR':
        return GoogleFonts.notoSansKr().fontFamily;
      case 'NanumGothic':
        return GoogleFonts.nanumGothic().fontFamily;
      case 'NanumMyeongjo':
        return GoogleFonts.nanumMyeongjo().fontFamily;
      case 'NanumPen':
        return GoogleFonts.nanumPenScript().fontFamily;
      default:
        return null;
    }
  }
}

