import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/updateaddress.dart';
import 'package:homefoo_users/userprofile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Addaddress extends StatefulWidget {
  const Addaddress({super.key});

  @override
  State<Addaddress> createState() => _AddaddressState();
}

class _AddaddressState extends State<Addaddress> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  List<Map<String, dynamic>> address = [];

  @override
  void initState() {
    super.initState();
    getaddress(); // Fetch addresses when screen loads
  }

  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getaddress() async {
    try {
      var userId = await getUserIdFromPrefs();
      var token = await gettokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/addresses/$userId/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
print("======================${response.body}");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        setState(() {
          address = productsData.map<Map<String, dynamic>>((data) {
            return {
              'id': data['id'],
              'complete_address': data['complete_address'],
              'city': data['city'],
              'postal_code': data['postal_code'],
              'Land_mark': data['Land_mark'],
            };
          }).toList();
        });
      }
    } catch (error) {
      print("Error fetching addresses: $error");
    }
  }

  void addaddress() async {
    final token = await gettokenFromPrefs();

    try {
      var userId = await getUserIdFromPrefs();

      var response = await http.post(
        Uri.parse('$api/add-address/'),
        headers: {
          'Authorization': '$token',
        },
        body: {
          "user": userId,
          "complete_address": addressController.text,
          "city": cityController.text,
          "postal_code": pincodeController.text,
          "Land_mark": landmarkController.text,
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Address added successfully!'),
          ),
        );

        // Clear input fields after adding address
        addressController.clear();
        cityController.clear();
        pincodeController.clear();
        landmarkController.clear();

        // Refresh address list
        getaddress();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to add address. Please try again.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

 void deleteAddress(int id) async {
    try {
      var token = await gettokenFromPrefs();

      var response = await http.delete(
        Uri.parse('$api/deleteaddresses/$id/'),
        headers: {
          'Authorization': '$token',
        },
      );
print(response.statusCode);
print(response.body);
      if (response.statusCode == 204) {
        getaddress();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Address deleted successfully!'),
          ),
        );
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserProfile()));
          },
        ),
        title: const Text(
          "Add Address",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField("Address", addressController,
                      isEditable: true),
                  _buildTextField("City", cityController, isEditable: true),
                  _buildTextField("Pincode", pincodeController,
                      isEditable: true),
                  _buildTextField("Landmark", landmarkController,
                      isEditable: true),

                  const SizedBox(height: 20),

                  // Add Address Button
                  ElevatedButton(
                    onPressed: addaddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Add",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Display Address List
                  address.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: address.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white,
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                address[index]
                                                        ['complete_address'] ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "City: ${address[index]['city'] ?? ''}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "Pincode: ${address[index]['postal_code'] ?? ''}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "Landmark: ${address[index]['Land_mark'] ?? ''}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () {

                                                Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) => Updateaddress(address:address[index]['id'])));
                                                // Add your edit functionality here
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                deleteAddress(address[index]['id']);
                                                // Add your delete functionality here
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "No addresses found!",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(String label, TextEditingController? controller,
    {bool isEditable = true}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      controller: controller,
      enabled: isEditable,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
  );
}
