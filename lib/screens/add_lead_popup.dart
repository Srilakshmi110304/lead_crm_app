import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AddLeadPopup extends StatefulWidget {
  const AddLeadPopup({super.key});

  @override
  _AddLeadPopupState createState() => _AddLeadPopupState();
}

class _AddLeadPopupState extends State<AddLeadPopup> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String phone = "";
  String email = "";
  String propertyType = "2BHK";
  String city = "";
  String address = "";
  bool isLoading = false;

  final List<String> propertyTypes = ["2BHK", "3BHK", "4BHK", "Villa", "Penthouse", "Studio"];

  Future<void> submitLead() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      Map<String, dynamic> leadData = {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim().isEmpty ? null : email.trim(),
        'property_type': propertyType,
        'city': city.trim().isEmpty ? null : city.trim(),
        'address': address.trim().isEmpty ? null : address.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      // Remove null values
      leadData.removeWhere((key, value) => value == null);

      // Insert lead data
      final response = await Supabase.instance.client.from('leads').insert(leadData).select();

      print('Lead saved successfully: $response');

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lead Added Successfully! 🎉"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving lead: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 700),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  ),
                ),
                child: AppBar(
                  title: const Text(
                    "Add New Lead",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Full Name *",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                      onChanged: (v) => name = v,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Phone Number *",
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter valid phone number';
                        }
                        return null;
                      },
                      onChanged: (v) => phone = v,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter valid email';
                          }
                        }
                        return null;
                      },
                      onChanged: (v) => email = v,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      value: propertyType,
                      decoration: const InputDecoration(
                        labelText: "Property Type",
                        prefixIcon: Icon(Icons.home_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: propertyTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (v) => propertyType = v.toString(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "City",
                        prefixIcon: Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => city = v,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Address",
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (v) => address = v,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : submitLead,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        "SAVE LEAD",
                        style: TextStyle(
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
      ),
    );
  }
}