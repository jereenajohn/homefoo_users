import 'package:flutter/material.dart';

class Offer extends StatefulWidget {
  const Offer({super.key});

  @override
  State<Offer> createState() => _OfferState();
}

class _OfferState extends State<Offer> {
  final TextEditingController field1Controller = TextEditingController();
  final TextEditingController field2Controller = TextEditingController();
  final TextEditingController field3Controller = TextEditingController();
  final TextEditingController field4Controller = TextEditingController();
  final TextEditingController field5Controller = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // void handleSubmit() {
  //   // Handle form submission logic here
  //   print("Title: \${field1Controller.text}");
  //   print("Description: \${field2Controller.text}");
  //   print("Discount Percentage: \${field3Controller.text}");
  //   print("Start Date: \${startDate?.toLocal().toString().split(' ')[0]}");
  //   print("End Date: \${endDate?.toLocal().toString().split(' ')[0]}");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offer Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: field1Controller, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: field2Controller, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: field3Controller, decoration: const InputDecoration(labelText: "Discount Percentage")),
            ListTile(
              title: Text(startDate == null ? "Select Start Date" : "Start Date: \${startDate?.toLocal().toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text(endDate == null ? "Select End Date" : "End Date: \${endDate?.toLocal().toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: handleSubmit,
            //   child: const Text("Submit"),
            // ),
          ],
        ),
      ),
    );
  }
}
