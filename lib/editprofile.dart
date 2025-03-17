import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/userprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Map<String, dynamic> customer = {};
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchUserDetails() async {
    try {
      var userId = await getUserIdFromPrefs();
      var token = await getTokenFromPrefs();

      final response = await http.get(Uri.parse('$api/customer/$userId/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body)['data'];

        setState(() {
          customer = userData;
          nameController.text = customer['name'];
          emailController.text = customer['email'];
          phoneController.text = customer['phone'];
        });
      }
    } catch (error) {
      print('Error fetching user: $error');
    }
  }


  
  Future<void> updateuserdetails() async {
    try {
      final token = await getTokenFromPrefs();
      final userId = await getUserIdFromPrefs();

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ID not found'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Token not found'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      var response = await http.put(
        Uri.parse('$api/update-user/$userId/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
          },
        ),
      );

      print("[[[[[[[=================${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EditProfile()),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid token, please log in again'),
            duration: Duration(seconds: 2),
          ),
        );
        // Handle token refresh or re-login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          duration: Duration(seconds: 2),
        ),
      );
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
            Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfile()));
          },
        ),
        title: const Text("Your Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture with Edit Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("lib/assets/proo.png"), // Replace with actual image
                ),
                // CircleAvatar(
                //   radius: 16,
                //   backgroundColor: Colors.white,
                //   child: Icon(Icons.edit, color: Colors.black, size: 18),
                // ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField("Name", nameController, isEditable: true),
                  _buildTextField("Mobile", phoneController, isEditable: true),
                  _buildTextField("Email", emailController, isEditable: true),

                  const SizedBox(height: 20),

                  // Update Profile Button
                  ElevatedButton(
                    onPressed: () {
                      updateuserdetails();
                      // Implement save logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Professional green color
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3, // Adding a slight shadow for a premium look
                    ),
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildTextField(String label, TextEditingController? controller,
      {bool isEditable = true, bool changeable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        enabled: isEditable,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
          suffixIcon: changeable
              ? TextButton(
                  onPressed: () {
                    // Handle change action
                  },
                  child: const Text(
                    "CHANGE",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
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
          // filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }
}