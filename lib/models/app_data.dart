import 'package:flutter/material.dart';

class AppDataModel extends ChangeNotifier {
  //
  String startAddress = '';
  String destinationAddress = '';

  String requestId = '';
  String offerId = '';

  double tripFare = 0.0;

// GETTERS
  String get getStartAddress => startAddress;
  String get getDestinationAddress => destinationAddress;
  String get getRequest => requestId;
  String get getTffer => offerId;
  double get getTripFare => tripFare;

  void updateStartAddress(String address) {
    startAddress = address;
    notifyListeners();
  }

  void updateDestinationAddress(String address) {
    destinationAddress = address;
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
