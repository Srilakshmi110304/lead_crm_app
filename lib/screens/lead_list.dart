import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';
import 'lead_detail.dart';
import 'site_visits_screen.dart';

class LeadList extends StatefulWidget {
  const LeadList({super.key});

  @override
  _LeadListState createState() => _LeadListState();
}

class _LeadListState extends State<LeadList> {
  List leads = [];
  final TextEditingController searchController = TextEditingController();
  Map<String, bool> siteVisitStatus = {};

  @override
  void initState() {
    super.initState();
    fetchLeads();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchLeads() async {
    try {
      final data = await Supabase.instance.client.from('leads').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() => leads = data);
        await fetchSiteVisitStatus();
      }
    } catch (e) {
      print('Error fetching leads: $e');
    }
  }

  Future<void> fetchSiteVisitStatus() async {
    try {
      final Map<String, bool> statusMap = {};
      for (var lead in leads) {
        final visits = await Supabase.instance.client
            .from('site_visits')
            .select()
            .eq('lead_id', lead['id'].toString())
            .eq('status', 'completed');
        statusMap[lead['id'].toString()] = visits.isNotEmpty;
      }
      if (mounted) {
        setState(() {
          siteVisitStatus = statusMap;
        });
      }
    } catch (e) {
      print('Error fetching site visit status: $e');
    }
  }

  void searchLeads(String value) async {
    if (value.isEmpty) {
      fetchLeads();
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('leads')
          .select()
          .ilike('name', '%$value%');

      if (mounted) {
        setState(() => leads = data);
        await fetchSiteVisitStatus();
      }
    } catch (e) {
      print('Error searching leads: $e');
    }
  }

  void exportToCSV() {
    List<List<String>> csvData = [
      ['Name', 'Phone', 'Email', 'Property Type', 'City', 'Address', 'Site Visit Status']
    ];

    for (var lead in leads) {
      bool isCompleted = siteVisitStatus[lead['id'].toString()] ?? false;
      csvData.add([
        lead['name'] ?? '',
        lead['phone'] ?? '',
        lead['email'] ?? '',
        lead['property_type'] ?? '',
        lead['city'] ?? '',
        lead['address'] ?? '',
        isCompleted ? 'Completed' : 'Pending',
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    debugPrint(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("CSV Exported successfully! Check console for data"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> startSiteVisit(Map<String, dynamic> lead) async {
    final result = await showDialog(
      context: context,
      builder: (context) => SiteVisitDialog(lead: lead),
    );

    if (result == true) {
      await fetchLeads();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Leads",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E3A8A)),
            onPressed: fetchLeads,
            tooltip: "Refresh",
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF1E3A8A)),
            onPressed: exportToCSV,
            tooltip: "Export CSV",
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Color(0xFF1E3A8A)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SiteVisitsScreen()),
              ).then((_) => fetchLeads());
            },
            tooltip: "Site Visits",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search by name...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: searchLeads,
              ),
            ),
          ),
          Expanded(
            child: leads.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No leads found",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: fetchLeads,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                    ),
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: leads.length,
              itemBuilder: (context, index) {
                final lead = leads[index];
                final isVisitCompleted = siteVisitStatus[lead['id'].toString()] ?? false;

                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LeadDetail(lead: lead),
                          ),
                        );
                        await fetchLeads();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (!isVisitCompleted) {
                                    startSiteVisit(lead);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isVisitCompleted
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isVisitCompleted
                                            ? Icons.check_circle
                                            : Icons.camera_alt,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isVisitCompleted ? "Completed" : "Start Visit",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.transparent,
                                      child: Text(
                                        (lead['name'] ?? '?')[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lead['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.home, size: 12, color: Colors.grey.shade500),
                                            const SizedBox(width: 4),
                                            Text(
                                              lead['property_type'] ?? 'No type',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(Icons.location_city, size: 12, color: Colors.grey.shade500),
                                            const SizedBox(width: 4),
                                            Text(
                                              lead['city'] ?? 'No city',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
                                            const SizedBox(width: 4),
                                            Text(
                                              lead['phone'] ?? 'No phone',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Color(0xFF3B82F6),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}