import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool darkMode = false;
  String selectedLanguage = 'English';
  String selectedTheme = 'Blue';
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        userData = {
          'email': user.email,
          'name': user.userMetadata?['name'] ?? 'User',
          'created_at': user.createdAt,
        };
      });
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData?['name'] ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData?['email'] ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Active",
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings Sections
            _buildSettingsSection(
              title: "Preferences",
              icon: Icons.settings_applications,
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: "Push Notifications",
                  subtitle: "Receive alerts about site visits",
                  value: notifications,
                  onChanged: (value) {
                    setState(() => notifications = value);
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: "Dark Mode",
                  subtitle: "Switch to dark theme",
                  value: darkMode,
                  onChanged: (value) {
                    setState(() => darkMode = value);
                  },
                ),
                _buildDropdownTile(
                  icon: Icons.language,
                  title: "Language",
                  subtitle: "Choose your preferred language",
                  value: selectedLanguage,
                  items: ['English', 'Hindi', 'Telugu', 'Tamil'],
                  onChanged: (value) {
                    setState(() => selectedLanguage = value!);
                  },
                ),
                _buildDropdownTile(
                  icon: Icons.palette,
                  title: "Theme Color",
                  subtitle: "Choose app theme color",
                  value: selectedTheme,
                  items: ['Blue', 'Green', 'Purple', 'Orange'],
                  onChanged: (value) {
                    setState(() => selectedTheme = value!);
                  },
                ),
              ],
            ),

            _buildSettingsSection(
              title: "Account",
              icon: Icons.account_circle,
              children: [
                _buildMenuTile(
                  icon: Icons.lock,
                  title: "Change Password",
                  subtitle: "Update your password",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Change password feature coming soon!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Icons.email,
                  title: "Email Settings",
                  subtitle: "Manage email preferences",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Email settings coming soon!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Icons.privacy_tip,
                  title: "Privacy Policy",
                  subtitle: "Read our privacy policy",
                  onTap: () {
                    _showInfoDialog("Privacy Policy",
                        "Your data is secure with us. We use industry-standard encryption to protect your information.");
                  },
                ),
                _buildMenuTile(
                  icon: Icons.description,
                  title: "Terms of Service",
                  subtitle: "Read terms and conditions",
                  onTap: () {
                    _showInfoDialog("Terms of Service",
                        "By using this app, you agree to our terms of service. We reserve the right to update these terms at any time.");
                  },
                ),
              ],
            ),

            _buildSettingsSection(
              title: "Support",
              icon: Icons.support_agent,
              children: [
                _buildMenuTile(
                  icon: Icons.help,
                  title: "Help Center",
                  subtitle: "Get help and support",
                  onTap: () {
                    _showInfoDialog("Help Center",
                        "Contact support at: support@propertycrm.com\n\nCall: +1 234 567 8900");
                  },
                ),
                _buildMenuTile(
                  icon: Icons.feedback,
                  title: "Send Feedback",
                  subtitle: "Help us improve",
                  onTap: () {
                    _showFeedbackDialog();
                  },
                ),
                _buildMenuTile(
                  icon: Icons.star,
                  title: "Rate Us",
                  subtitle: "Rate this app on the store",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Thank you for rating us! ⭐"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog();
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Version Info
            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF3B82F6)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3B82F6),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF8B5CF6)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFF59E0B)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Send Feedback"),
        content: TextField(
          controller: feedbackController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "Tell us what you think...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thank you for your feedback! 🙏"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}