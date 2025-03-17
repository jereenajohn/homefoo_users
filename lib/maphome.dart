import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:homefoo_users/api.dart';
import 'package:homefoo_users/home.dart';
import 'package:homefoo_users/rest.items.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/animation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> restaurants = [];
  Set<Marker> _markers = {};
  Set<Circle> _circles = {}; // Define a set to hold the circles
  LatLng initialLocation = const LatLng(9.9469883, 76.2762553);
  final String restaurantsEndpoint = "https://nirvana-rose-insulation-wishes.trycloudflare.com/restaurants/";

  bool isRestaurantSelected = false;
  Map<String, dynamic>? selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition().then((_) {
      if (_currentPosition != null) {
        fetchRestaurants();
      }
    });
    startMarkerUpdateTimer(); // Start the timer to update markers
  }

  String? _currentAddress;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('Service Enabled: $serviceEnabled');
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
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
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
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

        // Add a circle for the 5 km radius
        Circle circle = Circle(
          circleId: CircleId('radius'),
          center: initialLocation,
          radius: 5000, // 5 km radius
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue,
          strokeWidth: 1,
        );
        _circles.add(circle);
      });
      print('Current Position: $_currentPosition');
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
    try {
      await placemarkFromCoordinates(
              _currentPosition!.latitude, _currentPosition!.longitude)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              ' ${place.subLocality} ${place.subAdministrativeArea}';
              print('Current Addressssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss: $_currentAddress');
        });
      }).catchError((e) {
        debugPrint(e);
      });
    } catch (e) {
      debugPrint(e.toString());
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
    final response = await http.get(Uri.parse('$api/restaurants/'));
    print('Response: ${response.statusCode}');
    print('Responseeeeeeeeeeeeeeeeeee: ${response.body}');

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final List<dynamic> restaurantsData = parsed['data'];
      print('Restaurant Data: $restaurantsData');

      // Filter restaurants within 5 km radius
      final filteredRestaurants = restaurantsData.where((restaurantData) {
        final String? latitude = restaurantData['latitude'];
        final String? longitude = restaurantData['longitude'];

        if (latitude == null || longitude == null) {
          return false;
        }

        final double restaurantLat = double.parse(latitude);
        final double restaurantLng = double.parse(longitude);
        final double distanceInMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          restaurantLat,
          restaurantLng,
        );
        return distanceInMeters <= 5000; // 5 km radius
      }).toList();

      setState(() {
        restaurants = filteredRestaurants.cast<Map<String, dynamic>>();
        addMarkers(); // Add markers after fetching restaurants
      });
    } else {
      throw Exception('Failed to load restaurants');
    }
  } catch (error) {
    print('Error fetching restaurants: $error');
  }
}

// Future<BitmapDescriptor> _createCustomMarker(String imageUrl) async {
//   final Completer<BitmapDescriptor> completer = Completer();
//   final ImageConfiguration config = ImageConfiguration();

//   NetworkImage(imageUrl).resolve(config).addListener(
//     ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) async {
//       final ByteData? byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
//       final Uint8List bytes = byteData!.buffer.asUint8List();

//       // Resize the image to a smaller size
//       final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 200, targetHeight: 200);
//       final ui.FrameInfo frameInfo = await codec.getNextFrame();
//       final ByteData? resizedByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
//       final Uint8List resizedBytes = resizedByteData!.buffer.asUint8List();

//       final BitmapDescriptor bitmapDescriptor = BitmapDescriptor.fromBytes(resizedBytes);
//       completer.complete(bitmapDescriptor);
//     }),
//   );

//   return completer.future;
// }


Future<BitmapDescriptor> _createCustomMarker(String imageUrl) async {
  final Completer<BitmapDescriptor> completer = Completer();
  final ImageConfiguration config = ImageConfiguration();

  NetworkImage(imageUrl).resolve(config).addListener(
    ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) async {
      final ByteData? byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List bytes = byteData!.buffer.asUint8List();

      // Resize the image to a smaller size and make it circular
      final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 100, targetHeight: 100);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ByteData? resizedByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List resizedBytes = resizedByteData!.buffer.asUint8List();

      // Create a circular image with a white border
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint = Paint()..isAntiAlias = true;
      final double radius = 50.0;
       canvas.drawCircle(Offset(radius, radius), radius, paint);
      paint.blendMode = BlendMode.srcIn;
      canvas.drawImageRect(
        frameInfo.image,
        Rect.fromLTWH(0, 0, frameInfo.image.width.toDouble(), frameInfo.image.height.toDouble()),
        Rect.fromLTWH(0, 0, radius * 2, radius * 2),
        paint,
      );
      final ui.Image circularImage = await pictureRecorder.endRecording().toImage(radius.toInt() * 2, radius.toInt() * 2);
      final ByteData? circularByteData = await circularImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List circularBytes = circularByteData!.buffer.asUint8List();

      final BitmapDescriptor bitmapDescriptor = BitmapDescriptor.fromBytes(circularBytes);
      completer.complete(bitmapDescriptor);
    }),
  );
   return completer.future;
}
void addMarkers() async {
  // Clear existing markers
  _markers.clear();

  for (var restaurantData in restaurants) {
    String? productImageUrl;
    if (restaurantData['last_product'] != null) {
      productImageUrl = "$api${restaurantData['last_product']['image1']}";
    }

    BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
    if (productImageUrl != null) {
      customIcon = await _createCustomMarker(productImageUrl);
    }

    // Create an animation controller for the fade transition
    final AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    final Animation<double> fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    final Animation<Color?> colorAnimation = ColorTween(begin: Colors.transparent, end: Colors.yellow.withOpacity(0.5)).animate(controller);

    // Start the fade-in animation
    controller.forward();

    Marker marker = Marker(
      markerId: MarkerId(restaurantData['id'].toString()),
      position: LatLng(
        double.parse(restaurantData['latitude']),
        double.parse(restaurantData['longitude']),
      ),
      icon: customIcon,
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

    // Add the marker directly to the _markers set
    _markers.add(marker);

    // Use the fade animation to control the marker's visibility
    fadeAnimation.addListener(() {
      setState(() {
        // Trigger a rebuild to apply the fade animation
      });
    });

    // Start the fade-out animation after a delay
    Future.delayed(const Duration(seconds: 5), () {
      controller.reverse();
    });

    // Loop the fade-in and fade-out animation
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }
  setState(() {
    _markers = _markers;
  });
}

// Call addMarkers repeatedly using a Timer
void startMarkerUpdateTimer() {
  Timer.periodic(const Duration(seconds: 5), (timer) {
    addMarkers();
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
                          "$api${restaurantItem?['image']}",
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
        Expanded(
          flex: 2,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 14,
            ),
            markers: _markers,
            circles: _circles, // Add circles to the map
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
            onTap: () {
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
                          "$api${selectedRestaurant?['image']}",
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