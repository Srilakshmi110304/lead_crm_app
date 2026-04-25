import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class SiteVisitsScreen extends StatefulWidget {
  const SiteVisitsScreen({super.key});

  @override
  _SiteVisitsScreenState createState() => _SiteVisitsScreenState();
}

class _SiteVisitsScreenState extends State<SiteVisitsScreen> {
  List<Map<String, dynamic>> leads = [];
  List<Map<String, dynamic>> siteVisits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      final leadsData = await Supabase.instance.client.from('leads').select().order('created_at', ascending: false);
      final visitsData = await Supabase.instance.client.from('site_visits').select();

      setState(() {
        leads = List<Map<String, dynamic>>.from(leadsData);
        siteVisits = List<Map<String, dynamic>>.from(visitsData);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> addSiteVisit(Map<String, dynamic> lead) async {
    final result = await showDialog(
      context: context,
      builder: (context) => SiteVisitDialog(lead: lead),
    );

    if (result == true) {
      fetchData();
      // Also trigger refresh in leads list
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Site visit completed! Refresh leads list to see update."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  bool isVisitCompleted(String leadId) {
    return siteVisits.any((visit) =>
    visit['lead_id'].toString() == leadId && visit['status'] == 'completed');
  }

  List<Map<String, dynamic>> getCompletedVisits(String leadId) {
    return siteVisits.where((visit) =>
    visit['lead_id'].toString() == leadId && visit['status'] == 'completed').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Site Visits",
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
            onPressed: fetchData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leads.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No leads available",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leads.length,
        itemBuilder: (context, index) {
          final lead = leads[index];
          final completed = isVisitCompleted(lead['id'].toString());
          final visits = getCompletedVisits(lead['id'].toString());

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
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lead['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  Text(
                                    lead['property_type'] ?? 'No property type',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: completed ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    completed ? Icons.check_circle : Icons.pending,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    completed ? "Completed" : "Pending",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey.shade500),
                            const SizedBox(width: 8),
                            Text(
                              lead['phone'] ?? 'No phone',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.location_city, size: 16, color: Colors.grey.shade500),
                            const SizedBox(width: 8),
                            Text(
                              lead['city'] ?? 'No city',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.home, size: 16, color: Colors.grey.shade500),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lead['address'] ?? 'No address',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (visits.isNotEmpty && visits[0]['photos'] != null && (visits[0]['photos'] as List).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Visit Photos:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      ...(visits[0]['photos'] as List).map((photo) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: NetworkImage(photo.toString()),
                                              fit: BoxFit.cover,
                                              onError: (error, stackTrace) {
                                                print('Error loading image: $error');
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                                if (visits[0]['remarks'] != null && visits[0]['remarks'] != '')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      "📝 ${visits[0]['remarks']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!completed)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => addSiteVisit(lead),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Start Site Visit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SiteVisitDialog extends StatefulWidget {
  final Map<String, dynamic> lead;

  const SiteVisitDialog({super.key, required this.lead});

  @override
  _SiteVisitDialogState createState() => _SiteVisitDialogState();
}

class _SiteVisitDialogState extends State<SiteVisitDialog> {
  List<Uint8List> photos = [];
  final TextEditingController remarksController = TextEditingController();
  bool isSubmitting = false;

  Future<void> pickPhotos() async {
    final picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      for (var img in images) {
        final bytes = await img.readAsBytes();
        photos.add(bytes);
      }
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${images.length} photo(s) selected"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void removePhoto(int index) {
    setState(() {
      photos.removeAt(index);
    });
  }

  Future<String> uploadPhotoToStorage(Uint8List bytes, int index) async {
    try {
      // Generate unique filename with timestamp and random string
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomStr = DateTime.now().microsecondsSinceEpoch.toString().substring(8);
      final fileName = 'visit_${widget.lead['id'].toString().substring(0, 8)}_${timestamp}_$index.jpg';

      print('📤 Uploading: $fileName (${bytes.length} bytes)');

      // Upload to Supabase storage
      await Supabase.instance.client.storage
          .from('site_visits')
          .uploadBinary(fileName, bytes);

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('site_visits')
          .getPublicUrl(fileName);

      print('✅ Upload successful: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Upload error for photo $index: $e');
      rethrow;
    }
  }

  Future<void> submitVisit() async {
    if (photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload at least one photo"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      List<String> photoUrls = [];

      // Show progress indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text("Uploading ${photos.length} photo(s)..."),
              const SizedBox(height: 8),
              Text(
                "Please wait",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );

      // Upload photos one by one
      for (var i = 0; i < photos.length; i++) {
        try {
          final url = await uploadPhotoToStorage(photos[i], i);
          photoUrls.add(url);
        } catch (e) {
          print('Failed to upload photo $i: $e');
          // Continue with other photos
        }
      }

      // Close progress dialog
      if (context.mounted) Navigator.pop(context);

      if (photoUrls.isEmpty) {
        throw Exception('No photos were uploaded successfully. Please check your internet connection and try again.');
      }

      final visitData = {
        'lead_id': widget.lead['id'],
        'lead_name': widget.lead['name'],
        'visit_date': DateTime.now().toIso8601String(),
        'photos': photoUrls,
        'remarks': remarksController.text.trim().isEmpty ? null : remarksController.text.trim(),
        'status': 'completed',
      };

      // Check if visit already exists
      final existingVisits = await Supabase.instance.client
          .from('site_visits')
          .select()
          .eq('lead_id', widget.lead['id'].toString());

      if (existingVisits.isNotEmpty) {
        await Supabase.instance.client
            .from('site_visits')
            .update(visitData)
            .eq('lead_id', widget.lead['id'].toString());
        print('Updated existing site visit');
      } else {
        await Supabase.instance.client.from('site_visits').insert(visitData);
        print('Inserted new site visit');
      }

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Site visit completed! ${photoUrls.length} photo(s) uploaded"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error submitting visit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 650),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Site Visit: ${widget.lead['name']}",
                style: const TextStyle(fontSize: 18),
              ),
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Property Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("📍 ${widget.lead['address'] ?? 'Address not provided'}"),
                        Text("🏠 ${widget.lead['property_type'] ?? 'Property type not provided'}"),
                        Text("📞 ${widget.lead['phone'] ?? 'Phone not provided'}"),
                        Text("📧 ${widget.lead['email'] ?? 'Email not provided'}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Select photos from your gallery to upload",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: isSubmitting ? null : pickPhotos,
                    icon: const Icon(Icons.photo_library),
                    label: Text("Select Photos (${photos.length} selected)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (photos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: MemoryImage(photos[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => removePhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Remarks / Notes",
                      hintText: "Add any observations or notes...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : submitVisit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: photos.isNotEmpty ? const Color(0xFF10B981) : Colors.grey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      photos.isNotEmpty
                          ? "Complete Site Visit (${photos.length} Photos)"
                          : "Select photos to continue",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}