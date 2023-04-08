import 'dart:ffi';

class TripData {
  String? criteria;
  String? dropoff;
  String? fare;
  String? pickup;
  List<String>? userIds;

  TripData({this.criteria, this.dropoff, this.fare, this.pickup, this.userIds});
}

class TripDataResponse {
  String? id;
  String? criteria;
  String? dropoff;
  String? fare;
  String? pickup;
  List<String>? userIds;

  TripDataResponse(
      {this.id,
      this.criteria,
      this.dropoff,
      this.fare,
      this.pickup,
      this.userIds});
}
