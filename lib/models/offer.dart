import 'dart:ffi';

class Offer {
  String? userId;
  String? tripId;

  Offer({this.userId, this.tripId});
}

class OfferResponse {
  String? id;
  String? userId;
  String? tripId;

  OfferResponse({this.id, this.userId, this.tripId});
}
