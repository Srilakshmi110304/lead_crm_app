import 'package:flutter/material.dart';
import 'add_lead_popup.dart';
import 'site_visits_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(icon, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF1E3A8A)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back! 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage your leads and site visits efficiently",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDashboardCard(
                  icon: Icons.people_alt,
                  title: "View Leads",
                  subtitle: "Manage all your property leads",
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.pushNamed(context, '/leads'),
                  index: 0,
                ),
                _buildDashboardCard(
                  icon: Icons.add_circle,
                  title: "Add New Lead",
                  subtitle: "Create a new property lead",
                  color: const Color(0xFF10B981),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddLeadPopup(),
                    );
                  },
                  index: 1,
                ),
                _buildDashboardCard(
                  icon: Icons.location_on,
                  title: "Site Visits",
                  subtitle: "Track and manage site visits",
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SiteVisitsScreen()),
                    );
                  },
                  index: 2,
                ),
                _buildDashboardCard(
                  icon: Icons.bar_chart,
                  title: "Analytics",
                  subtitle: "View statistics and reports",
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Analytics coming soon!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  index: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}