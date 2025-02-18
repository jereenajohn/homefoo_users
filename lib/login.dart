import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:homefoo_users/main.dart';
import 'package:homefoo_users/maphome.dart';
import 'package:homefoo_users/register.dart';



import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class login extends StatefulWidget {
  const login({super.key});

  

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  var url="https://6065-59-92-192-37.ngrok-free.app/login/";
  TextEditingController con1= TextEditingController();
  TextEditingController con2= TextEditingController();

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

   Future<void> storeUserId(String userId,String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
     await prefs.setString('token', token);
    
  }

  Future UserLogin() async {
    try {
      var response = await http.post(Uri.parse(url),
          body: {"email": con1.text, "password": con2.text});
      // if (response.statusCode == 200) {
      //   setState(() {
      //     var list2 = jsonDecode(response.body);

      //     print(list2);
      //     Navigator.push(context, MaterialPageRoute(builder: (context)=>MapScreen()));


      //   });
      // } 
       if (response.statusCode == 200) {
        var list2 = jsonDecode(response.body);
        var status = list2['status'];
        if (status == 'User Login is Successfully Completed') {
          var userId = list2['user_id'];
           // Extract user ID
            var token = list2['token'];
          setState(() {
            userId = userId.toString();
          });

          print("=========jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj$token");


          await storeUserId(userId,token); // Store user ID in shared preferences

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        }
      
      
      else {
        print("failed to load response");
      }}
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SingleChildScrollView(
        child: Container(
          child: Column(
          children: [
            Container(
        width: MediaQuery.of(context).size.width * 10,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),

          boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5), // Shadow color
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3), // changes position of shadow
      ),
    ],
        ),
        child:  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      children: [
        Image.asset(
          "lib/assets/logo.png",
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      ],
    ),
  ),
            ),
            SizedBox(height: 50), // Adds spacing between the container and text fields
            Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Welcome Back !",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
        ],
            ),
            SizedBox(height: 20,),
            Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(
          children: [
             TextField(
              controller: con1,
          decoration: InputDecoration(
            labelText: 'Username',
            
            border: OutlineInputBorder(
              borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
              borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
              borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
              borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.person),
            contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
        ),
        SizedBox(height: 20,),
        TextField(
           controller: con2,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
              borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
              borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
              borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.lock), // Changed icon to lock for password
            contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
        ),
        
          ],
        ),
            ),
           
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                children: [
                     Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                 GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>homefoo()));
                          },
                          child: Text("forgot Password ?",style: TextStyle(color: Color.fromARGB(255, 172, 172, 172) ),)),
                              ],
                            ),
                            SizedBox(height: 10,),
              
              
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                 GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Register()));
                          },
                          child: Text("Register a new membership",style: TextStyle(color: Color.fromARGB(255, 172, 172, 172) ),)),
                              ],
                            ),
              
                ],
              ),
            ),


          
           
            SizedBox(height: 20,),
            // Sign In Button
            Container(
        width: MediaQuery.of(context).size.width * 0.6, // Set button width as half of the screen width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), // Border radius for button
          color: const Color.fromARGB(255, 243, 33, 33),
        ),
        child: TextButton(
          onPressed: () {
            UserLogin();
  

            
          },
          child: Text(
            "Sign In",
            style: TextStyle(
              color: Colors.white, // Text color
              fontSize: 16.0,
            ),
          ),
        ),
            ),
            SizedBox(height: 40,),

            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 1,
                    width: 80,
                    color: Color.fromARGB(255, 215, 201, 201),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Or Sign In With",
                    style: TextStyle(
                      color: Color.fromARGB(255, 215, 201, 201),
                    ),
                  ),
                  SizedBox(width: 4),
                  Container(
                    height: 1,
                    width: 80,
                    color: Color.fromARGB(255, 215, 201, 201),
                  ),
                ],
              ),
              SizedBox(height: 20,),

Padding(
  padding: const EdgeInsets.all(15.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () {
            // Add Google sign-in functionality here
          },
          icon: Image.asset(
            'lib/assets/google.png', // Path to your Google logo image
            width: 24, // Adjust the width of the image as needed
            height: 24, // Adjust the height of the image as needed
          ),
          label: Text("Google", style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Google button color
            shadowColor: Colors.grey, // Box shadow color
            elevation: 5, // Elevation for box shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Border radius for button
            ),
          ),
        ),
      ),
      SizedBox(width: 20,), // Add spacing between buttons
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () {
            // Add Facebook sign-in functionality here
          },
          icon: Icon(Icons.facebook),
          label: Text("Facebook", style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Facebook button color
            shadowColor: Colors.grey, // Box shadow color
            elevation: 5, // Elevation for box shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Border radius for button
            ),
          ),
        ),
      ),
    ],
  ),
),




          ],
        )
        
        ),
      )

    
  );




  }
}