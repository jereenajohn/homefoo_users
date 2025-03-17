import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/rest.items.dart';
import 'package:http/http.dart' as http;


class CategoryWiseRestaurants extends StatefulWidget {
  final int categoryId;
  const CategoryWiseRestaurants({super.key, required this. categoryId});

  @override
  State<CategoryWiseRestaurants> createState() => _CategoryWiseRestaurantsState();
}

class _CategoryWiseRestaurantsState extends State<CategoryWiseRestaurants> {
  List<Map<String, dynamic>> restaurant = [];
    late List<bool> isFavorite;

@override
  void initState() {
    super.initState();
    fetchResturants();
    print("=================>>>>>>>>>>>${widget.categoryId}");
  }


 Future<void> fetchResturants() async {
    try {
      final response = await http.get(Uri.parse('$api/restaurants-by-category/${widget.categoryId}/'));
      print('Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> productsData = parsed['data'];
        List<Map<String, dynamic>> productsList = [];
        List<bool> favoritesList = [];

        for (var productData in productsData) {
          String imageUrl = "$api/${productData['image']}";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: Text(
        //   'Category Wise Restaurants',
        //   style: TextStyle(
        //     fontWeight: FontWeight.bold,
        //     fontSize: 20,
        //   ),
        // ),
        backgroundColor: const Color.fromARGB(255, 244, 244, 244),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add search functionality here
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Add notifications functionality here
            },
          ),
        ],
      ),
      body: restaurant.isNotEmpty
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
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: restaurant.length,
                      itemBuilder: (context, index) {
                        var restaurantItem = restaurant[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => rest_items(
                                    restaurant_id: restaurant[index]['id'],
                                    name: restaurant[index]['name'],
                                  ),
                                ),
                              );
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
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}