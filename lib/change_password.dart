import 'package:flutter/material.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldpasswordController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void changepassword() async {
    final token = await gettokenFromPrefs();

    print("tokennnnnnnnnn===============$token");

    try {
      var response = await http.put(
        Uri.parse('$api/change-password/'),
        headers: {
          'Authorization': '$token',
        },
        body: {
          "old_password": _oldpasswordController.text,
          "new_password": _newpasswordController.text,
          "confirm_password": _confirmpasswordController.text,
        },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Password Change successfully!'),
          ),
        );

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => home()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to change password.'),
          ),
        );
      }
    } catch (e) {
      print("errorrrrrrrrrrrrrrr: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.black,
            ),
            const SizedBox(height: 20),
            const Text(
              "CHANGE PASSWORD",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _oldpasswordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: "Enter Old Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newpasswordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: "Enter New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmpasswordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  changepassword();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
