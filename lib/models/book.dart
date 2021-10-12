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
      dateOfAdvertisement;
  List<String> images;

  Book({
    @required this.id,
    @required this.bookName,
    @required this.authorName,
    @required this.description,
    @required this.mrp,
    @required this.percentOfMRP,
    @required this.area,
    @required this.city,
    @required this.dateOfAdvertisement,
    @required this.images,
  });

  factory Book.fromJson(var jsonData, List<String> imagesURL) {
    List extractedData = jsonData['images'] as List;
    print(extractedData);
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
      images: extractedData.map((e) {
        // print("Debug $e");
        // print(e);
        return e.toString();
      }).toList(),
    );
  }
}
