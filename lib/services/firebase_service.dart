import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../services/local_notification.dart';

class FirebaseService {
  Future<void> postAdvertisement(Map<dynamic, dynamic> jsonData) async {
    try {
      final database = FirebaseDatabase.instance.reference();
      print("fetch data: $database");
      database.once().then((DataSnapshot snapshot) async {
        print('Data : ${snapshot.value}');

        String id;

        if (snapshot.value != null) {
          print(snapshot.value['booksArray']);
          final extractedData = snapshot.value['booksArray'] as List;
          print("extracted $extractedData");
          print(extractedData);
          id = extractedData.length.toString();
        } else {
          id = 0.toString();
          // _books = null;
        }
        uploadFile(jsonData['image'], id);

        FirebaseDatabase.instance
            .reference()
            .child('booksArray')
            .child(id)
            .set({
          "id": id,
          "bookName": jsonData['bookName'],
          "authorName": jsonData['authorName'],
          "description": jsonData['description'],
          "mrp": jsonData['mrp'],
          "percentOfMRP": jsonData['percentOfMRP'],
          "area": jsonData['area'],
          "city": jsonData['city'],
          "dateOfAdvertisement": jsonData['dateOfAdvertisement'].toString(),
          "image": id.toString()
        }).then((value) {
          LocalNotification.showNotification(
            title: 'Your ad is not live!',
            body:
                'Your advertisement for the book ${jsonData['bookName']} is posted',
          );
        });
      });
    } catch (error) {
      throw "no content";
    }
  }

  // List<String> preUpload(List<File> images, String id) {
  //   List<String> imageList = [];
  //   images.forEach((image) async {
  //     imageList.add('books/$id/${Path.basename(image.path)}');
  //     String imageURL = await uploadFile(image, id);
  //   });
  //   // print(imageList);
  //   return imageList;
  // }

  Future<String> uploadFile(File image, String id) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('books/$id');
    await storageReference.putFile(image).then((p0) => print("File Uploaded"));

    String returnURL;

    await storageReference.getDownloadURL().then((value) => returnURL = value);
    // print("returnURL $returnURL");
    return returnURL;
  }
}
