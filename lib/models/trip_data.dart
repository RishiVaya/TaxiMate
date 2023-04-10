import 'dart:ffi';

class TripData {
  String? criteria;
  String? dropoff;
  String? fare;
  String? pickup;
  List<String>? userIds;
}

class TripDataResponse {
  final String id;
  final Criteria criteria;
  final Address dropoff;
  final Address pickup;
  // List<String> userIds;

  TripDataResponse(this.id, this.criteria, this.dropoff, this.pickup);

  TripDataResponse.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        criteria = json["criteria"],
        dropoff = json["dropoff"],
        pickup = json["pickup"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "criteria": criteria,
        "dropoff": dropoff,
        "pickup": pickup,
      };
}

class Criteria {
  String desiredRating;
  String gender;

  Criteria(this.desiredRating, this.gender);
}

class Address {
  String address;
  double latitude;
  double longitude;

  Address(this.address, this.latitude, this.longitude);
}
