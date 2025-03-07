import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homefoo_users/ADMIN/update_categoy.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/userprofile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class update_Banners extends StatefulWidget {
  var id;
  update_Banners({super.key,required this.id});

  @override
  State<update_Banners> createState() => _update_BannersState();
}

class _update_BannersState extends State<update_Banners> {
  final TextEditingController category = TextEditingController();
 
  List<Map<String, dynamic>> Banner = [];

  @override
  void initState() {
    super.initState();
    getbanner(); // Fetch addresses when screen loads
    getbannerid();

  }

  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getbanner() async {
    try {
      var userId = await getUserIdFromPrefs();
      var token = await gettokenFromPrefs();
      var response = await http.get(
        Uri.parse('https://crown-florida-alabama-limitation.trycloudflare.com/admin/HOMFOO-banners/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
print("===========${response.body}");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['Banners'];

        setState(() {
          Banner = productsData.map<Map<String, dynamic>>((data) {
            return {
              'id': data['id'],
              'name': data['name'],
              'image': data['image'],
              
            };
          }).toList();
        });

        print('Addresses: $Banner');
      }
    } catch (error) {
      print("Error fetching addresses: $error");
    }
  }


  Future<void> getbannerid() async {
    try {
      var userId = await getUserIdFromPrefs();
      var token = await gettokenFromPrefs();
      var response = await http.get(
        Uri.parse('https://crown-florida-alabama-limitation.trycloudflare.com/admin/HOMFOO-update-banner/${widget.id}/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
      print("======================${response.statusCode}");
print("======================${response.body}");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed != null) {
          setState(() {
            category.text = parsed['name'] ?? '';
          });
          print('Banner details: $parsed');
        } else {
          print("Error: Response is null.");
        }
      }
    } catch (error) {
      print("Error fetching banner details: $error");
    }
  }

  void updatebanaer() async {
    final token = await gettokenFromPrefs();

    try {
      var userId = await getUserIdFromPrefs();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://crown-florida-alabama-limitation.trycloudflare.com/admin/HOMFOO-update-banner/${widget.id}/'),
      );

      request.headers['Authorization'] = '$token';

      request.fields['name'] = category.text;

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      var response = await request.send();
      print(response.statusCode);
      print(response.reasonPhrase);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Category added successfully!'),
          ),
        );

        // Clear input fields after adding category
        category.clear();
        setState(() {
          image = null;
        });

        // Refresh category list
        getbanner();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to add category. Please try again.'),
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

 void deletebaner(int id) async {
    try {
      var token = await gettokenFromPrefs();

      var response = await http.delete(
        Uri.parse('https://crown-florida-alabama-limitation.trycloudflare.com/admin/HOMFOO-delete-banner/$id/'),
        headers: {
          'Authorization': '$token',
        },
      );
print(response.statusCode);
print(response.body);
      if (response.statusCode == 200) {
        getbanner();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('deleted successfully!'),
          ),
        );
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }


  var image;
  final ImagePicker _picker = ImagePicker();
  Future<void> pickImagemain() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
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
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => UserProfile()));
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

                  _buildTextField("name", category, isEditable: true),


                  Stack(
                    children: [
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Select Main Image',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: image == null
                              ? IconButton(
                                  icon: Icon(Icons.image),
                                  onPressed: () => pickImagemain(), // Trigger image picker for this index
                                )
                              : null,
                        ),
                      ),
                      if (image != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            child: Image.file(
                              image,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Display picked image
                 
                  
                  // Add Address Button
                  ElevatedButton(
                    onPressed: updatebanaer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
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
                  Banner.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: Banner.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white,
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                Banner[index]['name'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 5),
                                              Banner[index]['image'] != null
                                                  ? Image.network(
                                                      'https://crown-florida-alabama-limitation.trycloudflare.com${Banner[index]['image']}',
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => update_Banners(id: Banner[index]['id'])));
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                deletebaner(Banner[index]['id']);
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
