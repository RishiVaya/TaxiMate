import 'dart:ffi';

class UserRequest {
  String? name;
  String? email;
  String? gender;
  Int? age;
  Int? rating;
}

class UserResponse {
  String? id;
  String? name;
  String? email;
  String? gender;
  Int? rating;

  UserResponse({this.id, this.name, this.email, this.gender, this.rating});
}
