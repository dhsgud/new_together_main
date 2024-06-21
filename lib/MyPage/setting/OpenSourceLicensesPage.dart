import 'package:flutter/material.dart';

class OpenSourceLicensesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오픈소스 라이선스'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('firebase_core'),
            subtitle: Text('Apache License 2.0'),
          ),
          ListTile(
            title: Text('firebase_auth'),
            subtitle: Text('Apache License 2.0'),
          ),
          ListTile(
            title: Text('firebase_database'),
            subtitle: Text('Apache License 2.0'),
          ),
          ListTile(
            title: Text('firebase_storage'),
            subtitle: Text('Apache License 2.0'),
          ),
          ListTile(
            title: Text('firebase_messaging'),
            subtitle: Text('Apache License 2.0'),
          ),
          ListTile(
            title: Text('flutter_local_notifications'),
            subtitle: Text('BSD 3-Clause "New" or "Revised" License'),
          ),
          ListTile(
            title: Text('cloud_firestore'),
            subtitle: Text('Apache License 2.0'),
          ),
          ListTile(
            title: Text('flutter_naver_map'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('flutter_location_search'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('font_awesome_flutter'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('shared_preferences'),
            subtitle: Text('BSD 3-Clause "New" or "Revised" License'),
          ),
          ListTile(
            title: Text('uuid'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('intl'),
            subtitle: Text('BSD 3-Clause "New" or "Revised" License'),
          ),
          ListTile(
            title: Text('location'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('http'),
            subtitle: Text('BSD 3-Clause "New" or "Revised" License'),
          ),
          ListTile(
            title: Text('permission_handler'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('geolocator'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('vibration'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('dash_chat_2'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('flutter_chat_ui'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('kpostal'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('flutter_inappwebview'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('paginated_search_bar'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('material_dialogs'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('google_fonts'),
            subtitle: Text('Apache License 2.0'),
          ),
          ListTile(
            title: Text('fluttertoast'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('icons_launcher'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('url_launcher'),
            subtitle: Text('BSD 3-Clause "New" or "Revised" License'),
          ),
          ListTile(
            title: Text('material_design_icons_flutter'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('cupertino_icons'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('shake'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('google_sign_in'),
            subtitle: Text('Apache License 2.0'),
          ),
          ListTile(
            title: Text('connectivity_plus'),
            subtitle: Text('MIT License'),
          ),
          ListTile(
            title: Text('flutter_bloc'),
            subtitle: Text('MIT License'),
          ),
        ],
      ),
    );
  }
}