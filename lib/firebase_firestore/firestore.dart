import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taximate/auth/auth.dart';

class Firestore {
  FirebaseFirestore firestoreDB = FirebaseFirestore.instance;

  Future<void> createFirestoreUser(String name, String email) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var userRef = firestoreDB.collection('users');
      var userMap = {"name": name, "email": email};

      userRef.doc(userId).set(userMap);
    }
  }

  Future<void> updateFirestoreUser(String name, String email) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;

      var userRef = firestoreDB.collection('users');
      var userMap = {"name": name, "email": email};

      userRef.doc(userId).set(userMap);
    }
  }

  Future<void> createCarpoolRequest(
      String name, String email, String tripDetails) async {
    var firebaseUser = await Auth().currentUser();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String tripId = "";

      var ref = firestoreDB.collection('carpool_request');
      var requestMap = {"status": "PENDING", userId: userId, tripId: tripId};

      ref.add(requestMap);
    }
  }
}
