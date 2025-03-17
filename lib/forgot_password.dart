import 'package:flutter/material.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/newpassword.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }
  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void sendemail() async {
    final token = await gettokenFromPrefs();

    try {
      var response = await http.post(
        Uri.parse('$api/forgot-password/'),
        headers: {
          'Authorization': '$token',
        },
        body: {
          "email": _emailController.text,
        },
      );
print(response.statusCode);
print(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('email send successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to send email.'),
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


 void verifyotp() async {
    final token = await gettokenFromPrefs();

    try {
      var response = await http.post(
        Uri.parse('$api/otp-verification/'),
        headers: {
          'Authorization': '$token',
        },
        body: {
          "email": _emailController.text,
          "otp": _otpController.text,
        },
      );
print(response.statusCode);
print(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('OTP Verified successfully!'),
          ),
        );

        Navigator.push(context, MaterialPageRoute(builder: (context)=>Newpassword(email: _emailController.text,)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to verify otp.'),
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
              "FORGET PASSWORD",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Provide your account's email for which you want to reset your password!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Email Input Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                hintText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black54),
                ),
                suffixIcon: TextButton(
                  onPressed: sendemail,
                  child: const Text(  
                    "Send Email",
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // OTP Input Field (Always Visible)
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: "Enter OTP",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  verifyotp();
                  // Add your logic for OTP verification and next step
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Verify OTP",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
