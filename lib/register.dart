import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:homefoo_users/home.dart';
import 'package:homefoo_users/main.dart';




import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  TextEditingController name= TextEditingController();
  TextEditingController email= TextEditingController();
  TextEditingController phone= TextEditingController();
  TextEditingController password= TextEditingController();
    TextEditingController Confirm= TextEditingController();
    var regurl="https://crown-florida-alabama-limitation.trycloudflare.com/register/";




   void RegisterUserData(
    String url,
    String name,
    String email,
    String phone,
    String password,
    BuildContext scaffoldContext,
  ) async {
    if (name.isEmpty || phone == 0 || email.isEmpty || password.isEmpty) {
      // Show SnackBar if any field is empty
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields.'),
        ),
      );
      return;
    }

    // if (!isValidEmail(email)) {
    //   // Show SnackBar for invalid email address
    //   ScaffoldMessenger.of(scaffoldContext).showSnackBar(
    //     SnackBar(
    //       content: Text('Please enter a valid email address.'),
    //     ),
    //   );
    //   return;
    // }

    try {
      var response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": name,
            "email": email,
            "phone": phone,
            "password": password
            
          }));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Registered Successfully.'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home()),
        );
      } else if (response.statusCode == 400) {
        // Show alert box for validation errors
        Map<String, dynamic> responseData = jsonDecode(response.body);
        Map<String, dynamic> data = responseData['data'];
        String errorMessage = data.entries.map((entry) => entry.value[0]).join('\n');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(errorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      // Show SnackBar for network error
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your connection.'),
        ),
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Builder(
        builder: (BuildContext scaffoldContext) {
          return SingleChildScrollView(
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
                SizedBox(height: 40), // Adds spacing between the container and text fields
                Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Register Now !",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            ],
                ),
                SizedBox(height: 10),
          
                Container(
                  child: Column(
                    children: [
          
                           
                Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Container(
              child: Column(
                children: [
                   TextField(
                    controller: name,
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
              SizedBox(height: 15,),
              TextField(
                 controller: email,
                decoration: InputDecoration(
                  labelText: 'email',
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
              SizedBox(height: 15,),
              TextField(
                 controller: phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
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
              SizedBox(height: 15,),
              TextField(
                 controller: password,
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
              SizedBox(height: 15,),
              TextField(
                controller: Confirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
              SizedBox(height: 15,),
              
              
                ],
              ),
            ),
                ),
               
          
                    ],
                  ),
                ),
               
             
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                
                        child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                     GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>homefoo()));
                              },
                              child: Text("Forgot Password ?",style: TextStyle(color:Color.fromARGB(255, 172, 172, 172)),)),
                              SizedBox(width: 100,),
          
                              GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>homefoo()));
                              },
                              child: Text("Register Now",style: TextStyle(color:Color.fromARGB(255, 172, 172, 172)),)),
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
               
                RegisterUserData(regurl,name.text,email.text,phone.text,password.text,scaffoldContext);
              },
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16.0,
                ),
              ),
            ),
                ),
                SizedBox(height: 30,),
          
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
                  SizedBox(height: 10,),
          
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
                'lib/assets/google.png', 
                width: 24, 
                height: 24, 
              ),
              label: Text("Google", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, 
                shadowColor: Colors.grey, 
                elevation: 5, 
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
          )
          
          
          
          
          
              ],
            )
            
            ),
          );
        }
      )

    
  );




  }
}