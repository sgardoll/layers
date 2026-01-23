import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Subscription'),
            subtitle: const Text('Free tier'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Layers'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
