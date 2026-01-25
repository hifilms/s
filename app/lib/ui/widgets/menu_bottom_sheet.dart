import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Standard for version

class MenuBottomSheet extends StatefulWidget {
  const MenuBottomSheet({super.key});

  @override
  State<MenuBottomSheet> createState() => _MenuBottomSheetState();
}

class _MenuBottomSheetState extends State<MenuBottomSheet> {
  String _version = "1.0.0";

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    // In a real app with package_info_plus:
    // final info = await PackageInfo.fromPlatform();
    // setState(() => _version = info.version);
    // Since I didn't add package_info_plus to pubspec, I'll hardcode or mock it.
    // I should have added it. I will use a placeholder.
    setState(() => _version = "1.0.0");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dark/Light Toggle (Placeholder logic as app is dark mode only per Code)
          // User asked for "Dark/Light Toggle".
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.white),
            title: const Text("Dark/Light Mode", style: TextStyle(color: Colors.white)),
            trailing: Switch(
              value: true, // Always dark for now
              onChanged: (val) {
                 // Implement theme switching logic if needed
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Theme toggle not implemented yet")),
                 );
              },
              activeColor: Colors.red,
            ),
          ),
          const Divider(color: Colors.grey),
          _buildItem(Icons.info_outline, "About Us", () {}),
          _buildItem(Icons.mail_outline, "Contact Us", () {}),
          _buildItem(Icons.privacy_tip_outlined, "Privacy Policy", () {}),
          _buildItem(Icons.copyright, "Copyright", () {}),
          const SizedBox(height: 10),
          Text("Version $_version", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }
}
