import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/categories.dart';
import 'package:homefoo_users/maphome.dart';
import 'package:homefoo_users/rest.items.dart';



import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentPosition();
    _startTimer();
    fetchBanners();
    fetchCategories();
    fetchResturents();
    fetchCatProducts();
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
              "https://6065-59-92-192-37.ngrok-free.app/${productData['image1']}";
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
              "https://6065-59-92-192-37.ngrok-free.app/${productData['image']}";
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
            height: 80,
          
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
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
                // Add search results here
              ],
            ),
          ),
        );
      },
    );
  }

  api a = api();
  PageController _pageController = PageController();
  var url = "https://6065-59-92-192-37.ngrok-free.app/admin/HOMFOO-categories";
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

  void _startTimer() {
    const Duration duration =
        Duration(seconds: 5); // Adjust the duration as needed
    _timer = Timer.periodic(duration, (Timer timer) {
      if (_pageController.hasClients) {
        if (_pageController.page == bannerImageBase64Strings.length - 1) {
          _pageController.animateToPage(0,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        } else {
          _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        }
      }
    });
  }

  // sharedpreference

  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
    }

//current location

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            ' ${place.subLocality} ${place.subAdministrativeArea}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
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

//banner

Future<void> fetchBanners() async {
  final String key = 'banner_data';
  String? localData = await getDataLocally(key);

  if (localData != null) {
    setState(() {
      // Use local data
      bannerImageBase64Strings = jsonDecode(localData)['banners'].cast<String>();
    });
  } else {
    try {
      final response = await http.get(Uri.parse(a.banner));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body)['data'];

        if (responseData is List) {
          List<String> base64Strings = [];

          for (var bannerData in responseData) {
            String imageUrl = "${a.base}" + bannerData['image'];
            base64Strings.add(await convertImageToBase64(imageUrl));
          }

          setState(() {
            bannerImageBase64Strings = base64Strings;
          });

          await storeDataLocally(key, jsonEncode({'banners': base64Strings}));
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load banners');
      }
    } catch (error) {
      print('Error fetching banners: $error');
    }
  }
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
   
      final response = await http.get(Uri.parse(url));


      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = jsonDecode(response.body)['data']; // Extract 'data' from response
        List<Map<String, dynamic>> categoriesList = [];

        for (var categoryData in categoriesData) {
             String imageUrl =
              "https://6065-59-92-192-37.ngrok-free.app${categoryData['image']}";
       
          categoriesList.add({
            'id': categoryData['id'],
            'name': categoryData['name'],
            'imageBase64': imageUrl,
          });
        }

        setState(() {
          categories = categoriesList;
        });

     
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>MapScreen()));

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
                  bannerImageBase64Strings.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 160,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: bannerImageBase64Strings.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: carouselWidth,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Image.memory(
                                  base64Decode(bannerImageBase64Strings[index]),
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                categories.isEmpty
  ? Center(child: CircularProgressIndicator())
  : SizedBox(
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 225, 225, 225),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Image.network(
                      categories[index]['imageBase64'], // Use image URL directly
                      width: 28,
                      height: 28,
                     
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
          );
        },
      ),
    

                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Recemmented Products",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Products != null
                      ? Container(
                          height:
                              200, // Set a fixed height for the horizontal list
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: Products.length,
                            itemBuilder: (context, index) {
                              var product = Products[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>productbigview(Products[index]['id'])));
                                  },
                                  child: Container(
                                    width:
                                        160, // Set the width of each item in the horizontal list
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                    255, 211, 210, 210)
                                                .withOpacity(0.5))),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            product['image'],
                                            width: 110,
                                            height: 110,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(product["name"],style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text(
                                                '\$ ${product['price']}',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),

                                                Row(
                                  children: [
                                    Image.asset(
                                      "lib/assets/rating.png",
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                                    Text("4.9 (30+ Review )"),
                                  ],
                                ),


                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(child: CircularProgressIndicator()),
                  SizedBox(
                    height: 10,
                  ),
                  restaurant != null
                      ? Container(
  color: const Color.fromARGB(255, 255, 255, 255),
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Explore Restaurants",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: restaurant.length,
        itemBuilder: (context, index) {
          var restaurantItem = restaurant[index];
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: GestureDetector(
              onTap: () {
            
                Navigator.push(context, MaterialPageRoute(builder: (context)=>rest_items(restaurant_id:restaurant[index]['id'],name:restaurant[index]['name'])));
                 
              },
              child: Container(
                height: 170,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 170,
                              width: 160,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                child: Image.network(
                                  restaurantItem['image'] ?? '',
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 0),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  restaurantItem["name"] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ' ${restaurantItem['location'] ?? ''}',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 116, 115, 115),
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Image.asset(
                                      "lib/assets/rating.png",
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                                    Text("4.9 (30+ Review )"),
                                  ],
                                ),
                                SizedBox(height: 40),
                                Row(
                                  children: [
                                    Image.asset(
                                      "lib/assets/offer.png",
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                                    Text(
                                      " 10% OFF Up to ₹80 ",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ],
  ),
)

                      : Center(
                          child:
                              CircularProgressIndicator(), // Show a loading indicator while fetching data
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
                      context, MaterialPageRoute(builder: (context) => categoriesview()));
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
