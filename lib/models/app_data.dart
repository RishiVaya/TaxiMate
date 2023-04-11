import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppDataModel extends ChangeNotifier {
  //
  Map<String, dynamic> startAddressObj = {
    "address": '',
    "latitude": 0.0,
    "longitude": 0.0
  };
  Map<String, dynamic> destinationAddressObj = {
    "address": '',
    "latitude": 0.0,
    "longitude": 0.0
  };

  String requestId = '';
  String offerId = '';

  double tripFare = 0.0;

  double latitude = 0.0;

  double longitude = 0.0;

// GETTERS
  Map<String, dynamic> get getStartAddress => startAddressObj;
  Map<String, dynamic> get getDestinationAddress => destinationAddressObj;
  String get getRequest => requestId;
  String get getOffer => offerId;
  double get getTripFare => tripFare;

  void updateStartAddress(String address, double latitude, double longitude) {
    startAddressObj = {
      "address": address,
      "latitude": latitude,
      "longitude": longitude
    };
    notifyListeners();
  }

  void updateDestinationAddress(
      String address, double latitude, double longitude) {
    destinationAddressObj = {
      "address": address,
      "latitude": latitude,
      "longitude": longitude
    };
    notifyListeners();
  }

  void updateRequestId(String id) {
    requestId = id;
    notifyListeners();
  }

  void updateOfferId(String id) {
    offerId = id;
    notifyListeners();
  }

  void updateFare(double fare) {
    tripFare = fare;
  }
}
