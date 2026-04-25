import 'package:flutter/material.dart';

class LeadDetail extends StatelessWidget {
  final Map<String, dynamic> lead;

  const LeadDetail({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Lead Details"),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.person, "Name", lead['name']?.toString() ?? 'N/A'),
                    const Divider(),
                    _buildDetailRow(Icons.email, "Email", lead['email']?.toString() ?? 'N/A'),
                    const Divider(),
                    _buildDetailRow(Icons.phone, "Phone", lead['phone']?.toString() ?? 'N/A'),
                    const Divider(),
                    _buildDetailRow(Icons.home, "Property Type", lead['property_type']?.toString() ?? 'N/A'),
                    const Divider(),
                    _buildDetailRow(Icons.location_city, "City", lead['city']?.toString() ?? 'N/A'),
                    const Divider(),
                    _buildDetailRow(Icons.location_on, "Address", lead['address']?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6A11CB), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}