import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:homefoo_users/api.dart';

class AddRestaurant extends StatefulWidget {
  const AddRestaurant({super.key});

  @override
  State<AddRestaurant> createState() => _AddRestaurantState();
}

class _AddRestaurantState extends State<AddRestaurant> {
  List<Map<String, dynamic>> restaurant = [];
  late List<bool> isFavorite;

  @override
  void initState() {
    fetchResturents();
    super.initState();
  }

  Future<void> fetchResturents() async {
    try {
      final response = await http.get(Uri.parse('$api/admin/HOMFOO-approved-restaurants/'));
      print('Response: ${response.statusCode}');
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed is List) {
          final List<dynamic> productsData = parsed;
          List<Map<String, dynamic>> productsList = [];
          List<bool> favoritesList = [];

          for (var productData in productsData) {
            if (productData is Map<String, dynamic>) {
              String imageUrl =
                  "$api${productData['image']}";
              productsList.add({
                'id': productData['id'],
                'name': productData['name'],
                'image': imageUrl,
                'location': productData['location'],
                'status': productData['status'],
              });

              favoritesList.add(false);
            } else {
              print('Invalid product data: $productData');
            }
          }

          setState(() {
            restaurant = productsList;
            isFavorite = favoritesList;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load category products');
      }
    } catch (error) {
      print('Error fetching category products: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approved Restaurant'),
      ),
      body: restaurant.isNotEmpty
          ? Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Approved Restaurants",
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 16,
                          //   ),
                          // ),
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
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => rest_items(
                              //       restaurant_id: restaurant[index]['id'],
                              //       name: restaurant[index]['name'],
                              //     ),
                              //   ),
                              // );
                            },
                            child: Container(
                              height: 150,
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
                                            height: 150,
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
                                        padding: const EdgeInsets.only(
                                            left: 20, bottom: 0),
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
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
                                                  color: Color.fromARGB(
                                                      255, 116, 115, 115),
                                                ),
                                              ),
                                              SizedBox(height: 5.0),
                                              // ElevatedButton(
                                              //   onPressed: () {
                                              //     // Add your approval logic here
                                              //   },
                                              //   style: ElevatedButton.styleFrom(
                                              //     backgroundColor: Colors
                                              //         .green, // Background color
                                              //   ),
                                              //   child: Text(
                                              //     'Approve',
                                              //     style: TextStyle(
                                              //         color: Colors.white),
                                              //   ),
                                              // ),
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
              ),
            )
          : Container(
              child: Center(
                child: Text("No restaurants available"),
              ),
            ),
    );
  }
}