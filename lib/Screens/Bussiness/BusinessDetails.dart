import 'package:flutter/material.dart';

import '../../Models/BusinessModel.dart';

class BusinessDetails extends StatefulWidget {
  final Business business;
  const BusinessDetails({super.key, required this.business});

  @override
  State<BusinessDetails> createState() => _BusinessDetailsState();
}

class _BusinessDetailsState extends State<BusinessDetails> {
  final _formKey = GlobalKey<FormState>();

  // NOTE: You can initialize these controllers with existing data here
  // if you were passing a Business object to this screen for editing.
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isChanged = false;


  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing business data
    _nameController.text = widget.business.name;
    _descriptionController.text = widget.business.description;
    _categoryController.text = widget.business.category;
    _locationController.text = widget.business.location;
    _phoneController.text = widget.business.phone;
    _websiteController.text = widget.business.website ?? '';
  }


  void _onChanged() {
    // Only update if the form is valid to prevent excessive state changes
    if (_formKey.currentState!.validate() && !_isChanged) {
      setState(() {
        _isChanged = true;
      });
    } else if (_isChanged && !_formKey.currentState!.validate()) {
      // Optionally reset isChanged if it becomes invalid,
      // but we typically keep it true until saved or reset.
    }
  }

  void _saveBusiness() {
    if (_formKey.currentState!.validate()) {
      final newBusiness = Business(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        location: _locationController.text,
        phone: _phoneController.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
        date: DateTime.now(),
      );

      print("Saved Business: ${newBusiness.name}");

      setState(() {
        _isChanged = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newBusiness.name} details saved successfully!'),
          backgroundColor: Colors.green.shade600, // Success color
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade100, // Light background for contrast
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Enhanced Header Section ---
              const Center(
                child: Text(
                  "Update Business Profile 🏢",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800, // Bolder font
                    color: Colors.blueGrey, // Softer color than pure blue
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Ensure all required details are accurate.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Form Wrapped in a Card for a premium look ---
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    onChanged: _onChanged,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Core Fields ---
                        _buildTextField(_nameController, "Business Name", Icons.store_mall_directory),
                        _buildTextField(_descriptionController, "Description", Icons.info_outline, maxLines: 3),
                        _buildTextField(_categoryController, "Category", Icons.category),
                        _buildTextField(_locationController, "Location", Icons.location_on),

                        const Divider(height: 30, thickness: 1, color: Colors.blueGrey),

                        // --- Contact Fields ---
                        _buildTextField(_phoneController, "Phone", Icons.phone, keyboardType: TextInputType.phone),
                        _buildTextField(_websiteController, "Website (optional)", Icons.language, keyboardType: TextInputType.url),

                        const SizedBox(height: 40),

                        // --- Save Button ---
                        ElevatedButton.icon(
                          onPressed: _isChanged ? _saveBusiness : null,
                          icon: const Icon(Icons.save, size: 24), // Added icon
                          label: const Text("Save Changes"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18), // Increased padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            // Dynamic color based on change state
                            backgroundColor: _isChanged ? Colors.blue.shade700 : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            elevation: _isChanged ? 10 : 0, // Higher elevation when enabled
                            shadowColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Updated _buildTextField for cooler look ---
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, { // Added required IconData
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Increased vertical padding
      child: Material(
        // Retain elevation for a lifted feel, but use less shadow color
        elevation: 4,
        shadowColor: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16), // Slightly larger text
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blue.shade400, size: 22), // Colored and sized icon
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 15 : 18, horizontal: 10),

            // Clean, non-existent border on default
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),

            // Strong blue line when focused
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.blue, width: 2.5), // Thicker focused border
            ),
            // Slightly raised border when enabled but not focused
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (value) {
            if ((value == null || value.isEmpty) && !label.contains("optional")) {
              return "The $label field is required.";
            }
            return null;
          },
        ),
      ),
    );
  }
}