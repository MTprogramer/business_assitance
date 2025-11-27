
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Dialogues/AddBusinessDialog.dart';

class AddBusinessScreen extends StatelessWidget {
  const AddBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Plus Button Box
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const AddBusinessDialog(),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Add Business",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}