import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/home.dart';


import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';

class categoriesview extends StatefulWidget {
  const categoriesview({super.key});

  @override
  State<categoriesview> createState() => _categoriesviewState();
}

class _categoriesviewState extends State<categoriesview> {
  void initState() {
    // TODO: implement initState
    super.initState();
    
    fetchCategories();
   
  }

  List<Map<String, dynamic>> restaurant = [];
  late List<bool> isFavorite;

  List<Map<String, dynamic>> Products = [];

  Future<void> fetchCatProducts() async {
    try {
      final response = await http.get(Uri.parse(a.productview));
      print('Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> productsData = parsed['data'];
        List<Map<String, dynamic>> productsList = [];
        List<bool> favoritesList = [];

        for (var productData in productsData) {
          // Fetch image URL
          String imageUrl =
              "https://crown-florida-alabama-limitation.trycloudflare.com/${productData['image1']}";
          // You might need to adjust the URL based on your API response structure

          productsList.add({
            'id': productData['id'],
            'category_id': productData['category'],
            'name': productData['name'],
            'price': productData['price'],
            'image': imageUrl,
            'offer': productData['offer'],
            'description': productData['description'],
          });

          favoritesList.add(false);
        }

        setState(() {
          Products = productsList;
          isFavorite = favoritesList;
        });
      } else {
        throw Exception('Failed to load category products');
      }
    } catch (error) {
      print('Error products: $error');
    }
  }


  //restaurantsssssssss

  Future<void> fetchResturents() async {
    try {
      final response = await http.get(Uri.parse(a.restaurants));
      print('Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> productsData = parsed['data'];
        List<Map<String, dynamic>> productsList = [];
        List<bool> favoritesList = [];

        for (var productData in productsData) {
          String imageUrl =
              "https://crown-florida-alabama-limitation.trycloudflare.com/${productData['image']}";
          productsList.add({
            'id': productData['id'],
            'name': productData['name'],
            'image': imageUrl,
            'owner_name': productData['owner_name'],
            'phone': productData['phone'],
            'email': productData['email'],
            'location': productData['location'],
            'status': productData['status'],
            'is_open': productData['is_open'],
            'longitude': productData['longitude'],
            'latitude': productData['latitude'],
          });

          favoritesList.add(false);
        }

        setState(() {
          restaurant = productsList;
          isFavorite = favoritesList;
        });
      } else {
        throw Exception('Failed to load category products');
      }
    } catch (error) {
      print('Error fetching category products: $error');
    }
  }

  int _index = 0;

  bool _isSearching = false;

  void _showSearchDialog(BuildContext context) {
    setState(() {
      _isSearching = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                          });
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
               
              ],
            ),
          ),
        );
      },
    );
  }

  api a = api();
  PageController _pageController = PageController();
  var url = "https://crown-florida-alabama-limitation.trycloudflare.com/categories/";
  late Timer _timer;
  List<String> bannerImageBase64Strings = [];
  String? _currentAddress;
  Position? _currentPosition;
  List<Map<String, dynamic>> categories = [];
  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  


  //local storage

  Future<void> storeDataLocally(String key, String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  Future<String?> getDataLocally(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<String> convertImageToBase64(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return base64Encode(response.bodyBytes);
    } else {
      throw Exception('Failed to load image: $imageUrl');
    }
  }

  //category

  Future<void> fetchCategories() async {
    try {
      final String key = 'categories_data';
      String? localData = await getDataLocally(key);

      if (localData != null) {
        setState(() {
          // Use local data
          categories = jsonDecode(localData).cast<Map<String, dynamic>>();
        });
      } else {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final List<dynamic> categoriesData = jsonDecode(response.body);
          List<Map<String, dynamic>> categoriesList = [];

          for (var categoryData in categoriesData) {
            String imageUrl = "${a.base}" + categoryData['image'];
            String base64Image = await convertImageToBase64(imageUrl);
            categoriesList.add({
              'id': categoryData['id'],
              'name': categoryData['name'],
              'imageBase64': base64Image,
            });
          }

          setState(() {
            categories = categoriesList;
          });

          // Store data locally
          await storeDataLocally(key, jsonEncode(categoriesList));
        } else {
          throw Exception('Failed to load categories');
        }
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double carouselWidth = screenWidth * 0.9;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
            child: Column(children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 183, 183, 183)
                      .withOpacity(0.5), // Shadow color
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],

              color: Colors.white, // Background color
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Column(
                    children: [
                      Image.asset(
                        "lib/assets/logo.png",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                  Text(
                    ' ${_currentAddress ?? ""}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          "lib/assets/notification.png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                   Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap:(){
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>map()));

                          },
                          child: Image.asset(
                            "lib/assets/loc_r.png",
                            width: 25,
                            height: 25,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 17,
          ),
          Padding(
            padding: const EdgeInsets.only(),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                 
                  SizedBox(
                    height: 10,
                  ),
                   categories.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : Container(
                            height: 800,
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 78,
                                            height: 78,
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 232, 232, 232),
                                              image: DecorationImage(
                                                image: MemoryImage(base64Decode(
                                                    categories[index]
                                                        ['imageBase64'])),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            categories[index]['name'],
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  SizedBox(
                    height: 10,
                  ),
                
                 

                ],
              ),
            ),
          ),
        ])),
      ),
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 244, 244, 244),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: GNav(
            gap: 20,
            onTabChange: (index) {
              setState(() {
                _index = index;
                if (index == 2) {
                  _showSearchDialog(context);
                }
              });
            },
            padding: EdgeInsets.all(16),
            selectedIndex: _index,
            tabs: [
              GButton(
                icon: Icons.home,
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => home()));
                  // Navigate to Home page
                },
              ),
              GButton(
                icon: Icons.shopping_bag,
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => home()));
                  // Navigate to Cart page
                },
              ),
              GButton(
                icon: Icons.search,
                onPressed: () {
                  // Show search dialog if tapped
                },
              ),
              GButton(
                icon: Icons.person,
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => home()));
                  // Navigate to Profile page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
