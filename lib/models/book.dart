import 'package:flutter/cupertino.dart';

class Book {
  String id,
      bookName,
      authorName,
      description,
      mrp,
      area,
      city,
      percentOfMRP,
      dateOfAdvertisement,
      latitude,
      longitude,
      image,
      ownerEmail;

  Book(
      {@required this.id,
      @required this.bookName,
      @required this.authorName,
      @required this.description,
      @required this.mrp,
      @required this.percentOfMRP,
      @required this.area,
      @required this.city,
      @required this.dateOfAdvertisement,
      @required this.latitude,
      @required this.longitude,
      @required this.image,
      @required this.ownerEmail});

  factory Book.fromJson(var jsonData) {
    return Book(
      id: jsonData['id'],
      bookName: jsonData['bookName'],
      authorName: jsonData['authorName'],
      description: jsonData['description'],
      mrp: jsonData['mrp'],
      percentOfMRP: jsonData['percentOfMRP'],
      area: jsonData['area'],
      city: jsonData['city'],
      dateOfAdvertisement: jsonData['dateOfAdvertisement'],
      image: jsonData['image'],
      latitude: jsonData['latitude'],
      longitude: jsonData['longitude'],
      ownerEmail: jsonData['ownerEmail'],
    );
  }
}
