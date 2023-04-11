import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taximate/components/bottom_navigation.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import 'package:taximate/models/app_data.dart';
import 'package:taximate/pages/criteria.dart';
import 'package:taximate/pages/secrets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:math' show cos, sqrt, asin;

import '../auth/auth.dart';

class MapViewR extends StatefulWidget {
  @override
  _MapViewRState createState() => _MapViewRState();
}

class _MapViewRState extends State<MapViewR> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = 'mcmaster';
  String _destinationAddress = 'richmond hill';
  String? _placeDistance;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {});
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    var appData = context.watch<AppDataModel>();

    var id = appData.requestId;

    double _coordinateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }

    Future<List<double>> _pickup() async {
      var offer = await Firestore().getOffer(id);
      var info = offer!['tripData'];
      var a = _coordinateDistance(
          info['pickup'][1]['latitude'],
          info['pickup'][1]['longitude'],
          info['dropoff'][0]['latitude'],
          info['dropoff'][0]['longitude']);
      var b = _coordinateDistance(
          info['pickup'][1]['latitude'],
          info['pickup'][1]['longitude'],
          info['dropoff'][1]['latitude'],
          info['dropoff'][1]['longitude']);

      if (a > b) {
        return [
          info['pickup'][0]['latitude'],
          info['pickup'][0]['longitude'],
          info['pickup'][1]['latitude'],
          info['pickup'][1]['longitude'],
          info['dropoff'][1]['latitude'],
          info['dropoff'][1]['longitude'],
          info['dropoff'][0]['latitude'],
          info['dropoff'][0]['longitude']
        ];
      }
      return [
        info['pickup'][0]['latitude'],
        info['pickup'][0]['longitude'],
        info['pickup'][1]['latitude'],
        info['pickup'][1]['longitude'],
        info['dropoff'][0]['latitude'],
        info['dropoff'][0]['longitude'],
        info['dropoff'][1]['latitude'],
        info['dropoff'][1]['longitude']
      ];
    }

    //var pickup = await Firestore().getOffer(id)['tripData'][];

    // Formula for calculating distance between two coordinates
    // https://stackoverflow.com/a/54138876/11910277

    // Create the polylines for showing the route between two places
    _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      List<double> infos,
    ) async {
      polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Secrets.API_KEY, // Google Maps API Key
        PointLatLng(startLatitude, startLongitude),
        PointLatLng(infos[2], infos[3]),
        //wayPoints: [PolylineWayPoint(location: "43.8563707,-79.3376825")],
        travelMode: TravelMode.driving,
      );
      print(result);

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      polylinePoints = PolylinePoints();
      PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
        Secrets.API_KEY, // Google Maps API Key
        PointLatLng(infos[2], infos[3]),
        PointLatLng(infos[4], infos[5]),
        //wayPoints: [PolylineWayPoint(location: "43.8563707,-79.3376825")],
        travelMode: TravelMode.driving,
      );
      print(result2);

      if (result2.points.isNotEmpty) {
        result2.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      polylinePoints = PolylinePoints();
      PolylineResult result3 = await polylinePoints.getRouteBetweenCoordinates(
        Secrets.API_KEY, // Google Maps API Key
        PointLatLng(infos[4], infos[5]),
        PointLatLng(destinationLatitude, destinationLongitude),
        //wayPoints: [PolylineWayPoint(location: "43.8563707,-79.3376825")],
        travelMode: TravelMode.driving,
      );
      print(result3);

      if (result3.points.isNotEmpty) {
        result3.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );
      polylines[id] = polyline;
    }

    // Method for calculating the distance between two places
    Future<bool> _calculateDistance() async {
      try {
        var infos = await _pickup();
        // Retrieving placemarks from addresses
        List<Location> startPlacemark =
            await locationFromAddress(_startAddress);
        List<Location> destinationPlacemark =
            await locationFromAddress(_destinationAddress);

        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        double startLatitude = infos[0];

        double startLongitude = infos[1];

        double destinationLatitude = infos[6];
        double destinationLongitude = infos[7];

        String startCoordinatesString = '($startLatitude, $startLongitude)';
        String destinationCoordinatesString =
            '($destinationLatitude, $destinationLongitude)';

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId(startCoordinatesString),
          position: LatLng(infos[0], infos[1]),
          infoWindow: InfoWindow(
            title: 'Start $startCoordinatesString',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId(destinationCoordinatesString),
          position: LatLng(infos[6], infos[7]),
          infoWindow: InfoWindow(
            title: 'Destination $destinationCoordinatesString',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        // Calculating to check that the position relative
        // to the frame, and pan & zoom the camera accordingly.
        double miny = (startLatitude <= destinationLatitude)
            ? startLatitude
            : destinationLatitude;
        double minx = (startLongitude <= destinationLongitude)
            ? startLongitude
            : destinationLongitude;
        double maxy = (startLatitude <= destinationLatitude)
            ? destinationLatitude
            : startLatitude;
        double maxx = (startLongitude <= destinationLongitude)
            ? destinationLongitude
            : startLongitude;

        double southWestLatitude = miny;
        double southWestLongitude = minx;

        double northEastLatitude = maxy;
        double northEastLongitude = maxx;

        // Accommodate the two locations within the
        // camera view of the map
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(northEastLatitude, northEastLongitude),
              southwest: LatLng(southWestLatitude, southWestLongitude),
            ),
            100.0,
          ),
        );

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator.bearingBetween(
        //   startLatitude,
        //   startLongitude,
        //   destinationLatitude,
        //   destinationLongitude,
        // );

        await _createPolylines(startLatitude, startLongitude,
            destinationLatitude, destinationLongitude, infos);

        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
        });
        print("TOTAL DISTANCE -------------------------");
        print(_placeDistance);
        return true;
      } catch (e) {}
      return false;
    }

    @override
    void initState() {
      super.initState();
      _getCurrentLocation();
    }

    Future<void> logout() async {
      try {
        await Auth().signOut();
        context.go('/login');
      } on FirebaseAuthException catch (e) {}
    }

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    int _currentIndex = 0;
    Map<int, String> pagesMap = {
      0: '/',
      1: '/mapsac',
      3: '/profile',
      2: '/offer'
    };

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          //SizedBox(height: 10),
                          //_textField(
                          //    label: 'Start',
                          //    hint: 'Choose starting point',
                          //    prefixIcon: Icon(Icons.looks_one),
                          //    suffixIcon: IconButton(
                          //      icon: Icon(Icons.my_location),
                          //      onPressed: () {
                          //        startAddressController.text = _currentAddress;
                          //        _startAddress = _currentAddress;
                          //      },
                          //    ),
                          //    controller: startAddressController,
                          //    focusNode: startAddressFocusNode,
                          //    width: width,
                          //    locationCallback: (String value) {
                          //      setState(() {
                          //        _startAddress = value;
                          //      });
                          //    }),
                          //SizedBox(height: 10),
                          //_textField(
                          //    label: 'Destination',
                          //    hint: 'Choose destination',
                          //    prefixIcon: Icon(Icons.looks_two),
                          //    controller: destinationAddressController,
                          //    focusNode: desrinationAddressFocusNode,
                          //    width: width,
                          //    locationCallback: (String value) {
                          //      setState(() {
                          //        _destinationAddress = value;
                          //      });
                          //    }),
                          //SizedBox(height: 10),
                          //Visibility(
                          //  visible: _placeDistance == null ? false : true,
                          //  child: Text(
                          //    'DISTANCE: $_placeDistance km',
                          //    style: TextStyle(
                          //      fontSize: 16,
                          //      fontWeight: FontWeight.bold,
                          //    ),
                          //  ),
                          //),
                          //SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: (_startAddress != '' &&
                                    _destinationAddress != '')
                                ? () async {
                                    startAddressFocusNode.unfocus();
                                    desrinationAddressFocusNode.unfocus();
                                    setState(() {
                                      if (markers.isNotEmpty) markers.clear();
                                      if (polylines.isNotEmpty)
                                        polylines.clear();
                                      if (polylineCoordinates.isNotEmpty)
                                        polylineCoordinates.clear();
                                      _placeDistance = null;
                                    });

                                    _calculateDistance()
                                        .then((isCalculated) {});
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Show Route'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //Expanded(
            //    child: Align(
            //        alignment: Alignment.bottomRight,
            //        child: ElevatedButton(
            //          onPressed: logout,
            //          child: const Text('LOGOUT'),
            //        ))),
            //Expanded(
            //    child: Align(
            //        alignment: Alignment.bottomLeft,
            //        child: ElevatedButton(
            //          onPressed: () {
            //            context.go('/profile');
            //          },
            //          child: const Text('PROFILE'),
            //        ))),
          ],
        ),
      ),
    );
  }
}
