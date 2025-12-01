

import 'package:business_assistance/Models/BusinessModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Widgets/InputWidgets.dart';

class AddBusinessDialog extends StatefulWidget {
  final Function(Business)? onSave;
  const AddBusinessDialog({super.key, this.onSave});

  @override
  State<AddBusinessDialog> createState() => _AddBusinessDialogState();
}

class _AddBusinessDialogState extends State<AddBusinessDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ------ Title ------
              const Text(
                "Add Your Business",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// ------ Business Name ------
              InputBix("Business Name", nameController),

              /// ------ Description ------
              InputBix("Description", descriptionController, maxLines: 3),

              /// ------ Category ------
              InputBix(
                  "Category (Shop / Restaurant / Service)", categoryController),

              /// ------ Location ------
              InputBix("Location / Address", locationController),

              /// ------ Phone ------
              InputBix("Phone Number", phoneController,
                  keyboard: TextInputType.phone),

              /// ------ Website ------
              InputBix("Website (Optional)", websiteController,
                  keyboard: TextInputType.url),

              const SizedBox(height: 20),

              /// ------ Buttons ------
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  /// Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// Save Button
                  ElevatedButton(
                    onPressed: () {
                      final businessData = Business(
                        name: nameController.text,
                        description: descriptionController.text,
                        category: categoryController.text,
                        location: locationController.text,
                        phone: phoneController.text,
                        website: websiteController.text,
                        date: DateTime.now(),
                      );
                      if (widget.onSave != null) {
                        widget.onSave!(businessData);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
