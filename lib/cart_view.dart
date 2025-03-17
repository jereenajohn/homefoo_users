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
import 'package:homefoo_users/login.dart';
import 'package:homefoo_users/maphome.dart';
import 'package:homefoo_users/rest.items.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';

class View_Cart extends StatefulWidget {
  const View_Cart({super.key});

  @override
  State<View_Cart> createState() => _View_CartState();
}

class _View_CartState extends State<View_Cart> {
  List<Map<String, dynamic>> cartdata = [];
  List<Map<String, dynamic>> address = [];
  int selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCartData();
    getaddress();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> getaddress() async {
    try {
      var userId = await getUserIdFromPrefs();
      var token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/addresses/$userId/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
      print("======================>>>>${response.body}");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        setState(() {
          address = productsData.map<Map<String, dynamic>>((data) {
            return {
              'id': data['id'],
              'complete_address': data['complete_address'],
              'city': data['city'],
              'postal_code': data['postal_code'],
              'Land_mark': data['Land_mark'],
            };
          }).toList();
        });
      }
    } catch (error) {
      print("Error fetching addresses: $error");
    }
  }

  Future<void> fetchCartData() async {
    try {
      final token = await getTokenFromPrefs();

      final response = await http.get(
        Uri.parse("$api/cart/"),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
      );

      print("cart data isssssssssss ${response.body}");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> cartsData = parsed['data'];
        List<Map<String, dynamic>> cartList = [];
        for (var cartData in cartsData) {
          var product = cartData['product'];
          cartList.add({
            'id': product['id'],
            'name': product['name'],
            'image': product['image1'],
            'quantity': cartData['quantity'],
            'price': product['price'],
          });
        }
        setState(() {
          cartdata = cartList;
        });
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (error) {
      print('Error fetching cart data: $error');
    }
  }

  Future<void> updateprice(var price) async {
    try {
      final token = await getTokenFromPrefs();

      var response = await http.put(
        Uri.parse('$api/api/orders/products/update-price/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'price': price,
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var item in cartdata) {
      final discountPerQuantity = item['discount'] ?? 0.0;
      int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final totalItemPrice = quantity * price;
      final totalDiscount = quantity * discountPerQuantity;
      total += totalItemPrice - totalDiscount;
    }
    return total;
  }

  Future<void> incrementquantity(int id, int quantity) async {
    try {
      final token = await getTokenFromPrefs();
      final response = await http.put(
        Uri.parse('$api/increment/$id/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'quantity': quantity,
        }),
      );
      print("response issssssssss ${response.body}");
      print(response.statusCode);

      if (response.statusCode == 200) {
        fetchCartData();
      } else {
        throw Exception('Failed to update cart item');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cart item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> decrementquantity(int id, int quantity) async {
    try {
      final token = await getTokenFromPrefs();
      final response = await http.put(
        Uri.parse('$api/decrement/$id/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'quantity': quantity,
        }),
      );
      print("response issssssssss ${response.body}");
      print(response.statusCode);

      if (response.statusCode == 200) {
        fetchCartData();
      } else {
        throw Exception('Failed to update cart item');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cart item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deletecartitem(int id) async {
    final token = await getTokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/cart/update/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        setState(() {
          cartdata.removeWhere((item) => item['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product deleted from Cart Successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to delete cart ID: $id');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete item from cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('token');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    await Future.delayed(Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login()),
    );
  }

  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  }
  void intialize(var selectedAddressIndex) {
    setState(() {
      selectedAddressIndex = selectedAddressIndex;
    });
  }

void showAddressSelectionSheet() {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: address.length,
                itemBuilder: (context, index) {
                  return RadioListTile<int>(
                    fillColor: MaterialStateProperty.all(Colors.green),
                    title: Column(
                      
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address[index]['complete_address']),
                        Text('City: ${address[index]['city']}'),
                        Text('Postal Code: ${address[index]['postal_code']}'),
                        Text('Landmark: ${address[index]['Land_mark']}'),
                        Divider(),
                      ],
                      
                    ),
                    
                    value: index,
                    groupValue: selectedAddressIndex,
                    onChanged: (int? value) {
                      setState(() {
                        selectedAddressIndex = value!;
                      });
                      Navigator.pop(context);
                      setState(() {
                        selectedAddressIndex = value!;
                      });

                      intialize(selectedAddressIndex);
                    },
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: SingleChildScrollView(
              child: Column(
                children: [ 
                  AppBar(
                    title: Text('Cart'),
                  ),
                  cartdata.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cartdata.length,
                          itemBuilder: (context, index) {
                            final item = cartdata[index];
                            final discountPerQuantity = item['discount'] ?? 0.0;
                            var quantity =
                                int.tryParse(item['quantity'].toString()) ?? 0;
                            final price =
                                double.tryParse(item['price'].toString()) ?? 0.0;
                                
                            final totalItemPrice = quantity * price;
                            final totalDiscount =
                                quantity * discountPerQuantity;
                            final discountedTotalPrice =
                                totalItemPrice - totalDiscount;

                            return Column(
                              children: [
                                InkWell(
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                "$api${item['image']}",
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(Icons
                                                      .image_not_supported);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['name'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (item['note'] != null &&
                                                      item['note'].isNotEmpty)
                                                    Text(
                                                      "Description: ${item['note']}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "₹${discountedTotalPrice.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.green,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 30,
                                                              height: 30,
                                                              child:
                                                                  IconButton(
                                                                icon: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    size: 16),
                                                                onPressed: () {
                                                                  if (quantity >
                                                                      0) {
                                                                    setState(
                                                                        () {
                                                                      quantity -=
                                                                          1;
                                                                    });
                                                                    decrementquantity(
                                                                        item[
                                                                            'id'],
                                                                        quantity);
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            Text(
                                                              "$quantity",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12),
                                                            ),
                                                            SizedBox(
                                                              width: 30,
                                                              height: 30,
                                                              child:
                                                                  IconButton(
                                                                icon: Icon(
                                                                    Icons.add,
                                                                    size: 16),
                                                                onPressed: () {
                                                                  setState(
                                                                      () {
                                                                    quantity +=
                                                                        1;
                                                                  });
                                                                  incrementquantity(
                                                                      item[
                                                                          'id'],
                                                                      quantity);
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: const Color.fromARGB(
                                      255, 240, 236, 236),
                                  thickness: 1,
                                ),
                              ],
                            );
                          },
                        ),
                        // Text("Select Address"),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: InkWell(
                      onTap: showAddressSelectionSheet,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.isNotEmpty
                                  ? address[selectedAddressIndex]['complete_address']
                                  : 'Loading...',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price: ₹${calculateTotalPrice().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>order_request()));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
