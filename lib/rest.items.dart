import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/home.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class rest_items extends StatefulWidget {
  var restaurant_id;
  var name;

  rest_items({Key? key, required this.restaurant_id, required this.name})
      : super(key: key);

  @override
  State<rest_items> createState() => _rest_itemsState();
}

class _rest_itemsState extends State<rest_items> {
  api a = api();
  List<Map<String, dynamic>> Products = [];
  late List<int> quantities;
  late List<bool> showQuantityButtonList;
  bool showQuantityButton = false;
  int _index = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
    initializeButtonVisibility();
  }

  void initializeButtonVisibility() {
    showQuantityButtonList = List.generate(Products.length, (index) => true);
    quantities = List.generate(Products.length, (index) => 0);
  }

  void incrementQuantity(int index) {
    setState(() {
      quantities[index]++;
      showQuantityButtonList[index] = true; // Set button visibility to true
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (quantities[index] > 0) {
        quantities[index]--;
      }
      if (quantities[index] == 0) {
        showQuantityButtonList[index] = false; // Set button visibility to false
      }
    });
  }

  void resetQuantity(int index) {
    setState(() {
      quantities[index] = 1;
      showQuantityButtonList[index] = true; // Set button visibility to true
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

//category

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
  List<Map<String, dynamic>> categories = [];

  Future<void> fetchCategories() async {
    try {
      final String key = 'categories_data';
      String? localData = await getDataLocally(key);

      if (localData != null) {
        setState(() {
          // Use local data
          categories = (jsonDecode(localData) as List<dynamic>)
              .cast<Map<String, dynamic>>();
        });
      } else {
        final response = await http.get(Uri.parse(a.cat));

        if (response.statusCode == 200) {
          final List<dynamic> categoriesData =
              jsonDecode(response.body)['data']; // Extract 'data' from response
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

          // Filter categories based on categoryIds list
          categoriesList
              .retainWhere((category) => categoryIds.contains(category['id']));

          setState(() {
            categories = categoriesList;
            print('ccccccccccccc$categories');
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

//products

  List<int> categoryIds = [];
  Future<void> fetchProducts() async {
    final token = await gettokenFromPrefs();
    print(a.rest_product + '${widget.restaurant_id}');
    try {
      var response = await http.post(Uri.parse(a.rest_product), headers: {
        'Authorization': '$token',
      }, body: {
        'token': token,
        'pk': widget.restaurant_id
      });

      print('Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> productsData = parsed['data'];
        List<Map<String, dynamic>> productsList = [];
        quantities = List.generate(productsData.length, (index) => 0);

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
          // Store category ID in the list if not already present
          if (!categoryIds.contains(productData['category'])) {
            categoryIds.add(productData['category']);
            print(categoryIds);
          }
        }

        setState(() {
          Products = productsList;
          print('uuuuuuuuuu$Products');
          initializeButtonVisibility();
        });
      } else {
        throw Exception('Failed to load category products');
      }
    } catch (error) {
      print('Error fetching category products: $error');
    }
  }

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
                // Add search results here
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 244, 244),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                color: Colors.white,
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
                        " ${widget.name}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              Products.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: Products.length,
                      itemBuilder: (context, index) {
                        var product = Products[index];

                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=>productbigview(Products[index]['id'])));
                            },
                            child: Container(
                              height: 190,
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 10, bottom: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 16.0),
                                            Text(
                                              product["name"],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17),
                                            ),
                                            SizedBox(height: 5.0),
                                            Text(
                                              '\$ ${product['price']}',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 2.0),
                                            Text(
                                              product["description"],
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            SizedBox(
                                              height: 50,
                                            ),
                                            Text(
                                              " 10% OFF Up to ₹80 ",
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                product['image'],
                                                width: 150,
                                                height: 115,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(height: 9),
                                            showQuantityButtonList[index]
                                                ? ElevatedButton(
                                                    onPressed: () =>
                                                        incrementQuantity(
                                                            index),
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .white), // Set background color to white
                                                      shape: MaterialStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0), // Set border radius
                                                          side: BorderSide(
                                                              color: Color.fromARGB(
                                                                  255,
                                                                  43,
                                                                  43,
                                                                  43)), // Set border color and width
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () =>
                                                              decrementQuantity(
                                                                  index),
                                                          icon: Icon(
                                                            Icons.remove,
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 1, 1, 1),
                                                          ),
                                                        ),
                                                        Text(
                                                          '${quantities[index]}',
                                                          style: TextStyle(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  3, 3, 3)),
                                                        ),
                                                        IconButton(
                                                          onPressed: () =>
                                                              incrementQuantity(
                                                                  index),
                                                          icon: Icon(
                                                            Icons.add,
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : ElevatedButton(
                                                    onPressed: () =>
                                                        resetQuantity(index),
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.white),
                                                      shape: MaterialStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          side: BorderSide(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  255)),
                                                        ),
                                                      ),
                                                      fixedSize:
                                                          MaterialStateProperty
                                                              .all<Size>(
                                                        Size(150.0,
                                                            50.0), // Set the width and height as per your requirement
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'ADD',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                          ],
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
                    )
                  : Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
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
