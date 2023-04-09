import 'dart:ffi';

class Request {
  String? userId;
  String? tripId;
  bool? status;

  Request({this.userId, this.tripId, this.status});
}

class RequestResponse {
  String? id;
  String? userId;
  String? tripId;

  RequestResponse({this.id, this.userId, this.tripId});
}
