import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homefoo_users/home.dart';
import 'package:homefoo_users/rest.items.dart';

import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> restaurants = [];
  Set<Marker> _markers = {};
  LatLng initialLocation = const LatLng(9.9469883, 76.2762553);
  final String restaurantsEndpoint = "https://crown-florida-alabama-limitation.trycloudflare.com/restaurants/";

  bool isRestaurantSelected = false;
  Map<String, dynamic>? selectedRestaurant;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
    _getCurrentPosition();
    
  }

  String? _currentAddress;
  Position? _currentPosition;

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

Future<void> _getCurrentPosition() async {
  final hasPermission = await _handleLocationPermission();

  if (!hasPermission) return;
  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((Position position) {
    setState(() {
      _currentPosition = position;
      initialLocation = LatLng(position.latitude, position.longitude); // Update initialLocation
    });
    _getAddressFromLatLng(_currentPosition!);

    // Add a marker for the current location
    Marker marker = Marker(
      markerId: MarkerId('currentLocation'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(title: 'Current Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Customize the marker icon if needed
    );
    _markers.add(marker);
  }).catchError((e) {
    debugPrint(e.toString());
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
                // Add search results here
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchRestaurants() async {
    try {
      final response = await http.get(Uri.parse(restaurantsEndpoint));
      print('Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> restaurantsData = parsed['data'];
        print('Restaurant Data: $restaurantsData');

        setState(() {
          restaurants = restaurantsData.cast<Map<String, dynamic>>();
          addMarkers(); // Add markers after fetching restaurants
        });
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (error) {
      print('Error fetching restaurants: $error');
    }
  }

  void addMarkers() {
    for (var restaurantData in restaurants) {
      Marker marker = Marker(
        markerId: MarkerId(restaurantData['id'].toString()),
        position: LatLng(
          double.parse(restaurantData['latitude']),
          double.parse(restaurantData['longitude']),
        ),
        infoWindow: InfoWindow(
          title: restaurantData['name'],
          snippet: restaurantData['location'],
        ),
        onTap: () {
          setState(() {
            selectedRestaurant = restaurantData;
            isRestaurantSelected = true;
          });
        },
      );
      _markers.add(marker);
    }
    setState(() {
      _markers = _markers;
    });
  }

Widget buildRestaurantDetails() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
   
    child: Row(
      children: restaurants.map((restaurantItem) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>rest_items(restaurant_id: restaurantItem['id'], name: restaurantItem['name'])));


              // setState(() {
              //   selectedRestaurant = restaurantItem;
              //   isRestaurantSelected = true;
              // });
            },
            child: Container(
              width: 320,
              height: 170, // Set a fixed width for each restaurant card
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
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: Image.network(
                          "https://crown-florida-alabama-limitation.trycloudflare.com/${restaurantItem?['image']}",
                          width: 130,
                          height: 170,
                          fit: BoxFit.cover,
                        ),
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
      }).toList(),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              padding: const EdgeInsets.only(top: 13),
              child: Row(
                children: [
                  Column(
                    children: [
                      Image.asset(
                        "lib/assets/logo.png",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ), Text(
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
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialLocation,
                zoom: 14,
              ),
              markers: _markers,
              onTap: (LatLng latLng) {
                setState(() {
                  selectedRestaurant = null;
                  isRestaurantSelected = false;
                });
              },
            ),
          ),
          
          if (!isRestaurantSelected)
            Expanded(
              flex: 1,
             
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Text("Swipe For More",style: TextStyle(color: const Color.fromARGB(255, 201, 200, 200)),),
                    buildRestaurantDetails(),
                  ],
                )
              
            ),
          if (isRestaurantSelected && selectedRestaurant != null)


           GestureDetector(
            onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (context)=>rest_items(restaurant_id: selectedRestaurant?['id'], name:selectedRestaurant?['name'])));

            },
             child: Container(
                width: 330,
                height: 180, // Set a fixed width for each restaurant card
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
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          child: Image.network(
                            "https://crown-florida-alabama-limitation.trycloudflare.com/${selectedRestaurant?['image']}",
                            width: 130,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 0),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  selectedRestaurant?["name"] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ' ${selectedRestaurant?['location'] ?? ''}',
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
           
             
            
        ],
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
