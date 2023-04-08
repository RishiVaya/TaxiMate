import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taximate/auth/auth.dart';

class Firestore {
  FirebaseFirestore firestoreDB = FirebaseFirestore.instance;

  Future<void> createFirestoreUser(String name, String email) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var userRef = firestoreDB.collection('users');
      var userMap = {"name": name, "email": email, "rating": 5, "gender": ""};

      userRef.doc(userId).set(userMap);
    }
  }

  Future<void> updateFirestoreUser(
    String name,
    String email,
    String gender,
  ) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var userRef = firestoreDB.collection('users');
      var userMap = {"name": name, "email": email};

      userRef.doc(userId).set(userMap);
    }
  }

  Future<void> createCarpoolRequest(String name, Object tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String tripId = "";

      var ref = firestoreDB.collection('carpool_request');
      var requestMap = {"accepted": false, userId: userId, tripId: tripId};

      ref.add(requestMap);
    }
  }

  Future<void> updateCarpoolRequest(String id, String name, String email,
      bool accepted, Object tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String tripId = "";

      var ref = firestoreDB.collection('carpool_request');
      var requestMap = {
        "accepted": accepted,
        "userId": userId,
        "tripId": tripId
      };

      ref.doc(id).set(requestMap, SetOptions(merge: true));
    }
  }

  Future<void> createOfferRequest(String name, Object tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String tripId = "";

      var ref = firestoreDB.collection('carpool_offer');
      var requestMap = {"status": "PENDING", userId: userId, tripId: tripId};

      ref.add(requestMap);
    }
  }

  Future<void> updateOfferRequest(
      String id, String name, String email, Object tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String tripId = "";

      var ref = firestoreDB.collection('carpool_offer');
      var requestMap = {
        "status": "PENDING",
        "userId": userId,
        "tripId": tripId
      };

      ref.doc(id).set(requestMap, SetOptions(merge: true));
    }
  }

  Future<void> addPassengerRating(Int rating, String passenger) async {
    var firebaseUser = await Auth().currentUser();

    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String tripId = "";

      var ref = firestoreDB.collection('ratings');
      var requestMap = {
        "userId": userId,
        "rating": rating,
        "passengerId": passenger
      };

      ref.add(requestMap);
    }
  }
}
