import 'package:flutter/material.dart';

import '../../../providers/app_settings_provider.dart';
import 'key_settings_screen.dart';
import '../dialogs/theme_dialog.dart';
import '../dialogs/font_family_dialog.dart';

class MyPageTab extends StatelessWidget {
  const MyPageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsProvider.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.vpn_key),
          title: const Text('키 설정'),
          subtitle: const Text('불렛 키 및 작업 상태 관리'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const KeySettingsScreen(),
                fullscreenDialog: false,
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('테마'),
          subtitle: Text(
            ThemeDialog.getThemeModeText(settings?.themeMode ?? ThemeMode.light),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ThemeDialog.show(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.font_download),
          title: const Text('글씨체'),
          subtitle: Text(
            FontFamilyDialog.getFontFamilyText(settings?.fontFamily),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            FontFamilyDialog.show(context);
          },
        ),
        const Divider(),
      ],
    );
  }
}

