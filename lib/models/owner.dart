import 'package:flutter/cupertino.dart';

class Owner {
  String name, contact, email;

  Owner({@required this.email, @required this.contact, @required this.name});

  factory Owner.fromJson(Map<dynamic, dynamic> jsonData) {
    return Owner(
      email: jsonData['email'],
      contact: jsonData['contact'],
      name: jsonData['name'],
    );
  }
}
