import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homefoo_users/ADMIN/add_banner.dart';
import 'package:homefoo_users/ADMIN/add_restaurant.dart';
import 'package:homefoo_users/ADMIN/categoreis.dart';
import 'package:homefoo_users/categories.dart';
import 'package:http/http.dart' as http;
import 'package:homefoo_users/api.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  void initState() {
    super.initState();
    fetchResturents();
  }

  api a = new api();
  List<Map<String, dynamic>> restaurant = [];
  late List<bool> isFavorite;


  Future<void> fetchResturents() async {
    try {
      final response = await http.get(Uri.parse(a.rest_pending));
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
                  "https://crown-florida-alabama-limitation.trycloudflare.com/${productData['image']}";
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
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      admin_categoriesview()));
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                                255, 216, 246, 186), // Background color
                            borderRadius:
                                BorderRadius.circular(10.0), // Border radius
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'lib/assets/burger.png', // Replace with your image path
                                width: 74,
                                height: 74,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                "Category",
                                style: TextStyle(
                                  color: Colors.white, // Text color
                                  fontSize: 16.0, // Font size
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: 8.0), // Add some space between the containers
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddRestaurant()));
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                                255, 246, 232, 186), // Background color
                            borderRadius:
                                BorderRadius.circular(10.0), // Border radius
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'lib/assets/pizza.png', // Replace with your image path
                                width: 74,
                                height: 74,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                "Add Resturants",
                                style: TextStyle(
                                  color: Colors.white, // Text color
                                  fontSize: 16.0, // Font size
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => admin_Banners()));
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                                255, 205, 239, 247), // Background color
                            borderRadius:
                                BorderRadius.circular(10.0), // Border radius
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'lib/assets/shawai.png', // Replace with your image path
                                width: 74,
                                height: 74,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                "Banners",
                                style: TextStyle(
                                  color: Colors.white, // Text color
                                  fontSize: 16.0, // Font size
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: 8.0), // Add some space between the containers
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 246, 186, 186), // Background color
                          borderRadius:
                              BorderRadius.circular(10.0), // Border radius
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'lib/assets/juice.png', // Replace with your image path
                              width: 74,
                              height: 74,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "Resturants",
                              style: TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 16.0, // Font size
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              restaurant.isNotEmpty
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
                                  "Pending  Restaurants",
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
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
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
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                    ),
                                                    child: Image.network(
                                                      restaurantItem['image'] ??
                                                          '',
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
                                                      restaurantItem["name"] ??
                                                          '',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                    // ...existing code...
                                                    Row(
                                                      children: [
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            // Add your approval logic here
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor: Colors
                                                                .green, // Background color
                                                          ),
                                                          child: Text(
                                                            'Approve',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                10), // Add some space between the buttons
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            // Add your rejection logic here
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor: Colors
                                                                .red, // Background color
                                                          ),
                                                          child: Text(
                                                            'Reject',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
// ...existing code...
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
                  : Container(
                      child: Center(
                        child: Text("No restaurants available"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
