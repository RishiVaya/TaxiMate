import 'dart:ffi';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> createOfferRequest(String name, Object tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String tripId = "";

      var ref = firestoreDB.collection('carpool_offer');
      var requestMap = {userId: userId, tripId: tripId};

      ref.add(requestMap);
    }
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
}
