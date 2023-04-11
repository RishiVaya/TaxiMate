import 'dart:ffi';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:taximate/auth/auth.dart';
import 'package:taximate/models/trip_data.dart';
import 'package:taximate/models/user.dart';

class Firestore {
  FirebaseFirestore firestoreDB = FirebaseFirestore.instance;

  Future<UserResponse?> createFirestoreUser(
    Map<String, dynamic> userData,
  ) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var userRef = firestoreDB.collection('users');

      userRef.doc(userId).set(userData);
    }
    return null;
  }

  Future<void> updateFirestoreUser(
    Map<String, dynamic> userData,
  ) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var userRef = firestoreDB.collection('users').doc(userId);

      userRef.update(userData).then((value) => print("Successfully updated"));
    }
  }

  Future<Map<String, dynamic>?> getFirestoreUser() async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var userRef = firestoreDB.collection('users');

      var user = await userRef.doc(userId).get();
      return user.data();
    }
    return null;
  }

  Future<String?> createCarpoolRequest(Map<String, dynamic> tripData) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      // String? tripId = await addTripData(tripDetails);

      // if (tripId == null) {
      //   return null;
      // }

      var ref = firestoreDB.collection('carpool_requests');
      var requestMap = {
        "userId": userId,
        "tripData": tripData,
        "accepted": false,
      };

      var reqId = await ref
          .add(requestMap)
          .then((documentSnapshot) => documentSnapshot.id);

      return reqId;
    } else {
      return null;
    }
  }

  Future<void> updateCarpoolRequestStatus(String id, bool accepted) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      var ref = firestoreDB.collection('carpool_requests').doc(id);
      var requestMap = {
        "accepted": accepted,
      };

      ref.update(requestMap).then((value) => print("Successfully updated"));
    }
  }

  Future<String?> createCarpoolOffer(Map<String, dynamic> tripData) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var ref = firestoreDB.collection('carpool_offers');
      var requestMap = {
        "userId": userId,
        "tripData": tripData,
        "active": true,
      };

      var offerId = await ref
          .add(requestMap)
          .then((documentSnapshot) => documentSnapshot.id);
      return offerId;
    }
    return null;
  }

  Future<void> updateOfferRequest(
      String id, String name, String email, Object tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String tripId = "";

      var ref = firestoreDB.collection('carpool_offer').doc(id);
      var offerMap = {"userId": userId, "tripId": tripId};

      ref.update(offerMap).then((value) => print("Successfully updated"));
    }
  }

  Future<void> updateOfferStatus(String offerId, bool status) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      var ref = firestoreDB.collection('carpool_offers').doc(offerId);

      ref.update({"active": status}).then(
          (value) => print("Successfully updated"));
    }
  }

  Future<void> addPassengerRating(Int rating, String passenger) async {
    var firebaseUser = await Auth().currentUser();

    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var ref = firestoreDB.collection('ratings');
      var requestMap = {
        "userId": userId,
        "rating": rating,
        "passengerId": passenger
      };

      ref.add(requestMap);
    }
  }

  Future<String?> addTripData(Map<String, dynamic> tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var ref = firestoreDB.collection('trip_data');

      var tripId = await ref
          .add(tripDetails)
          .then((documentSnapshot) => documentSnapshot.id);

      return tripId;
    }
    return null;
  }

  Future<List> getRelevantOffersByRequest(String reqId) async {
    var requestRef = firestoreDB.collection('carpool_requests');
    var offerRef = firestoreDB.collection('carpool_offers');
    var tripRef = firestoreDB.collection('trip_data');
    var userRef = firestoreDB.collection('users');

    // get request
    var request = {"id": reqId, ...?(await requestRef.doc(reqId).get()).data()};

    var reqTripDetails = (await tripRef.doc(request["tripId"]).get()).data();

    if (reqTripDetails == null) {
      return [];
    }

    // Request latitude and longtitude points
    var reqStartPoint = LatLng(reqTripDetails["pickup"]["latitude"],
        reqTripDetails["pickup"]["longitude"]);
    var reqEndPoint = LatLng(reqTripDetails["dropoff"]["latitude"],
        reqTripDetails["dropoff"]["longitude"]);

    // get active offers
    var activeOffers = (await offerRef.where("active", isEqualTo: true).get())
        .docs
        .map((doc) => {"id": doc.id, ...doc.data()});

    var offersList = [];

    print(activeOffers);

    for (var offer in activeOffers) {
      var offTripDetails = offer["tripData"];
      var offStartPoint = LatLng(offTripDetails!["pickup"]["latitude"],
          offTripDetails!["pickup"]["longitude"]);
      var offEndPoint = LatLng(offTripDetails["dropoff"]["latitude"],
          offTripDetails!["dropoff"]["longitude"]);
      List<LatLng> polylineOToO = [offStartPoint, offEndPoint];

      List<LatLng> polylineOToR = [offStartPoint, reqEndPoint];

      var startPointCheckOStartToOStart = PolygonUtil.isLocationOnPath(
          reqStartPoint, polylineOToO, false,
          tolerance: 8000);
      var endPointCheckOStartToOEnd = PolygonUtil.isLocationOnPath(
          reqEndPoint, polylineOToO, false,
          tolerance: 8000);

      var startPointCheckOStartToREnd = PolygonUtil.isLocationOnPath(
          reqStartPoint, polylineOToR, false,
          tolerance: 8000);
      var endPointCheckOStartToREnd = PolygonUtil.isLocationOnPath(
          offStartPoint, polylineOToR, false,
          tolerance: 8000);

      // If start and end points are within offeror's route, add to list
      if ((startPointCheckOStartToOStart && endPointCheckOStartToOEnd) ||
          (startPointCheckOStartToREnd && endPointCheckOStartToREnd)) {
        var offeror = (await userRef.doc(offer["userId"]).get()).data();
        var offerMap = {
          "tripData": {"offerId": offer["id"], ...offTripDetails},
          "userInfo": {...?offeror}
        };
        offersList.add(offerMap);
      }
    }

    print(offersList);

    return offersList;
  }

  Future<void> selectOffer(String offerId, String reqId) async {
    var requestRef = firestoreDB.collection('carpool_requests').doc(reqId);
    var offerRef = firestoreDB.collection('carpool_offers').doc(offerId);

    await requestRef.update({offerId: offerRef.id});
    await offerRef.update({
      "requests": FieldValue.arrayUnion([requestRef.id])
    });
  }

  Future<void> selectRequest(String offerId, String reqId) async {
    var requestRef = firestoreDB.collection('carpool_requests').doc(reqId);
    var offerRef = firestoreDB.collection('carpool_offers').doc(offerId);

    // Get request and offer data
    var offerData = (await offerRef.get()).data();
    var requestData = (await requestRef.get()).data();

    var offerDropoffs = offerData!["tripData"]["dropoff"];
    var requestDropoffs = requestData!["tripData"]["dropoff"];

    var combinedDropOffs = new List.from(offerDropoffs)
      ..addAll(requestDropoffs);

    var offerPickups = offerData!["tripData"]["pickup"];
    var requestPickups = requestData!["tripData"]["pickup"];

    var combinedPickups = new List.from(offerPickups)..addAll(requestPickups);

    //update trip info
    var offerTripData = await offerRef.update({
      "tripData.dropoff": combinedDropOffs,
      "tripData.pickup": combinedPickups,
    });
    var reqTripData = await requestRef.update({
      "tripData.dropoff": combinedDropOffs,
      "tripData.pickup": combinedPickups,
    });
  }

  Future<Map<String, dynamic>?> getOffer(String offerId) async {
    var offerRef =
        await firestoreDB.collection('carpool_offers').doc(offerId).get();

    var offer = {"id": offerId, ...?offerRef.data()};
    return offer;
  }

  Future<Map<String, dynamic>?> getRequest(String requestId) async {
    var requestRef =
        await firestoreDB.collection('carpool_requests').doc(requestId).get();

    var request = {"id": requestId, ...?requestRef.data()};
    return request;
  }

  Future<List> getRequestsForOffer(String offerId) async {
    var offerData =
        (await firestoreDB.collection('carpool_offers').doc(offerId).get())
            .data();
    var userRef = firestoreDB.collection('users');
    var tripRef = firestoreDB.collection('trip_data');

    var requestIds = offerData!["requests"];

    if (requestIds == null) {
      return [];
    }

    // Get requests
    var requestList = [];
    for (var reqId in requestIds) {
      var reqRes = await getRequest(reqId);
      requestList.add(reqRes);
    }

    // Get users and trip info for each request
    var combinedRequestList = [];
    for (var req in requestList) {
      var reqTripDetails = req["tripData"];
      var reqUser = (await tripRef.doc(req["userId"]).get()).data();
      combinedRequestList.add({
        "tripData": {"reqId": req["id"], ...?reqTripDetails},
        "userInfo": {...?reqUser}
      });
    }

    print("COMBINED: ${combinedRequestList}");

    return combinedRequestList;
  }
}
