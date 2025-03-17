import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:homefoo_users/addaddress.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/change_password.dart';
import 'package:homefoo_users/editprofile.dart';
import 'package:homefoo_users/forgot_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

   List<Map<String, dynamic>> customer = [];

  @override
  void initState() {
    super.initState();
    fetchuserdetails();
  }
var name;
var email;
  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
Future<void> fetchuserdetails() async {
  try {
    var userId = await getUserIdFromPrefs();
    var token = await gettokenFromPrefs();

    print('userIddddddddd: $userId');
    print('tokennnnnnnnnnn: $token');
    
    final response = await http.get(Uri.parse('$api/customer/$userId/'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final Map<String, dynamic> userData = responseData['data']; // Extract user object

      List<Map<String, dynamic>> userList = [];

      userList.add({
        'id': userData['id'],
        'name': userData['name'],
        'email': userData['email'],
        'phone': userData['phone'],
      });

      setState(() {
        customer = userList;
        name=userData['name'];
        email=userData['email'];
        print('ppppppppppppp==========$name');
        
      });
    }
  } catch (error) {
    print('Error fetching user: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Curved Background
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 148, 202, 246),
                  Colors.greenAccent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          // Profile Content
          Column(
            children: [
              const SizedBox(height: 60),

              // Profile Picture & Name
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                              "lib/assets/proo.png"), // Replace with actual image
                        ),
                        // Positioned(
                        //   bottom: 0,
                        //   right: 0,
                        //   child: CircleAvatar(
                        //     radius: 14,
                        //     backgroundColor: Colors.white,
                        //     child:
                        //         Icon(Icons.edit, size: 16, color: Colors.black),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (name != null)
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              name,
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),
                    if(email!=null)
                    Text(
                      "$email",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 70),

              // Menu Options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildMenuItem(
                      Icons.person,
                      "My Profile",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfile()),
                        );
                      },
                    ),
                     _buildMenuItem(
                      Icons.location_city,
                      "Address",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Addaddress()),
                        );
                      },
                    ),
                     _buildMenuItem(
                      Icons.location_city,
                      "Change Password",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChangePassword()),
                        );
                      },
                    ),
                    // _buildMenuItem(Icons.email, "Messages"),
                    _buildMenuItem(Icons.favorite, "Favourites"),
                    _buildMenuItem(Icons.location_on, "Location"),
                    _buildMenuItem(Icons.settings, "Settings"),
                    _buildMenuItem(Icons.logout, "Logout", isLogout: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildMenuItem(IconData icon, String title, {int? badgeCount, bool isLogout = false, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,  // Trigger navigation
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: isLogout ? Colors.red : Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: isLogout ? Colors.red : Colors.black),
            ),
          ),
          if (badgeCount != null)
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.black,
              child: Text(
                "$badgeCount",
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    ),
  );
}
}
