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

  Future<String?> createCarpoolRequest(Map<String, dynamic> tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String? tripId = await addTripData(tripDetails);

      if (tripId == null) {
        return null;
      }

      var ref = firestoreDB.collection('carpool_requests');
      var requestMap = {
        "userId": userId,
        "tripId": tripId,
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

  Future<String?> createCarpoolOffer(Map<String, dynamic> tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String? tripId = await addTripData(tripDetails);

      if (tripId == null) {
        return null;
      }

      var ref = firestoreDB.collection('carpool_offers');
      var requestMap = {
        "userId": userId,
        "tripId": tripId,
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
      var offTripDetails = (await tripRef.doc(offer["tripId"]).get()).data();
      var offStartPoint = LatLng(offTripDetails!["pickup"]["latitude"],
          offTripDetails!["pickup"]["longitude"]);
      var offEndPoint = LatLng(offTripDetails["dropoff"]["latitude"],
          offTripDetails!["dropoff"]["longitude"]);
      List<LatLng> polylineO = [offStartPoint, offEndPoint];
      List<LatLng> polylineR = [reqStartPoint, reqEndPoint];

      var startPointCheckO = PolygonUtil.isLocationOnPath(
          reqStartPoint, polylineO, false,
          tolerance: 8000);
      var endPointCheckO = PolygonUtil.isLocationOnPath(
          reqEndPoint, polylineO, false,
          tolerance: 8000);
      var startPointCheckR = PolygonUtil.isLocationOnPath(
          offStartPoint, polylineR, false,
          tolerance: 8000);
      var endPointCheckR = PolygonUtil.isLocationOnPath(
          offEndPoint, polylineR, false,
          tolerance: 8000);

      // If start and end points are within offeror's route, add to list
      if ((startPointCheckR && endPointCheckR) ||
          (startPointCheckO && endPointCheckO)) {
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

  Future<Map<String, dynamic>?> getOffer(String offerId) async {
    var offerRef =
        await firestoreDB.collection('carpool_offers').doc(offerId).get();

    var offer = {"id": offerId, ...?offerRef.data()};
    return offer;
  }
}
