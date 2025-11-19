import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/app_settings_provider.dart';

class FontFamilyDialog {
  static String getFontFamilyText(String? fontFamily) {
    if (fontFamily == null) {
      return '시스템 기본';
    }
    switch (fontFamily) {
      case 'NotoSansKR':
        return 'Noto Sans KR';
      case 'NanumGothic':
        return '나눔고딕';
      case 'NanumMyeongjo':
        return '나눔명조';
      case 'NanumPen':
        return '나눔펜';
      default:
        return fontFamily;
    }
  }

  static void show(BuildContext context) {
    final settings = AppSettingsProvider.of(context);
    if (settings == null) return;

    final fontFamilies = [
      (null, '시스템 기본'),
      ('NotoSansKR', 'Noto Sans KR'),
      ('NanumGothic', '나눔고딕'),
      ('NanumMyeongjo', '나눔명조'),
      ('NanumPen', '나눔펜'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('글씨체 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fontFamilies.map((font) {
            TextStyle? textStyle;
            if (font.$1 == null) {
              textStyle = null; // 시스템 기본
            } else {
              switch (font.$1) {
                case 'NotoSansKR':
                  textStyle = GoogleFonts.notoSansKr();
                  break;
                case 'NanumGothic':
                  textStyle = GoogleFonts.nanumGothic();
                  break;
                case 'NanumMyeongjo':
                  textStyle = GoogleFonts.nanumMyeongjo();
                  break;
                case 'NanumPen':
                  textStyle = GoogleFonts.nanumPenScript();
                  break;
                default:
                  textStyle = null;
              }
            }

            return RadioListTile<String?>(
              title: Text(font.$2, style: textStyle),
              value: font.$1,
              groupValue: settings.fontFamily,
              onChanged: (value) {
                settings.onFontFamilyChanged(value ?? '');
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}

