import 'dart:html' as html;
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as path;

import '../screens/home_page.dart';

import '../services/local_notification.dart';

class FirebaseService {
  Future<void> postAdvertisement(
      Map<dynamic, dynamic> jsonData, BuildContext context) async {
    try {
      final database = FirebaseDatabase.instance.reference();
      // print("fetch data: $database");
      database.once().then((DataSnapshot snapshot) async {
        // print('Data : ${snapshot.value}');

        String id;

        if (snapshot.value != null) {
          // print(snapshot.value['booksArray']);
          final extractedData = snapshot.value['booksArray'] as List;
          // print("extracted $extractedData");
          // print(extractedData);
          // ignore: unnecessary_null_comparison
          id = extractedData != null ? extractedData.length.toString() : '0';
        } else {
          id = 0.toString();
          // _books = null;
        }
        if (!kIsWeb) {
          uploadFromPhone(jsonData['image'], id);
        } else {
          // uploading logic done as soon as image is selected
          // uploadToStorage(imageWeb);
        }

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
          "image": id.toString(),
          "latitude": jsonData['latitude'],
          "longitude": jsonData['longitude'],
          "ownerEmail": jsonData['ownerEmail']
        }).then((value) {
          if (!kIsWeb) {
            LocalNotification.showNotification(
              title: 'Your ad is live!',
              body:
                  'Your advertisement for the book ${jsonData['bookName']} is posted',
            );
          }
          Navigator.of(context).pushReplacementNamed(HomePage.routeName);
        });
      });
    } catch (error) {
      throw "no content";
    }
  }

  Future<String> uploadFromPhone(File image, String id) async {
    print("uploadFile");
    Reference storageReference =
        FirebaseStorage.instance.ref().child('books/$id');

    await storageReference
        .putFile(image)
        .then((value) => print("File Uploaded"));
    late String returnURL;

    await storageReference.getDownloadURL().then((value) => returnURL = value);
    print("returnURL $returnURL");
    return returnURL;
  }

  uploadFromWeb(html.InputElement imageWeb) {
    final database = FirebaseDatabase.instance.reference();
    // print("fetch data: $database");
    database.once().then((DataSnapshot snapshot) async {
      String id;
      if (snapshot.value != null) {
        final extractedData = snapshot.value['booksArray'] as List;
        id = extractedData != null ? extractedData.length.toString() : '0';
      } else {
        id = 0.toString();
      }
      print("id isEmpty: " + id.isEmpty.toString());
      print("id value " + id);
      // if (!id.isEmpty) {
      imageWeb.onChange.listen((event) {
        final file = imageWeb.files?.first;
        final reader = html.FileReader();
        print("${reader.result.toString()} reus");
        reader.readAsDataUrl(file!);
        reader.onLoadEnd.listen((event) async {
          // print(imageWeb.value?.split('\\').last);
          print("${imageWeb.value?.split('\\').last} fileName");
          var snapshot = await FirebaseStorage.instance
              .ref()
              // .child('books/${id == '' ? '00' : id}')
              .child('books/$id')
              .putBlob(file);
          String downloadUrl = await snapshot.ref.getDownloadURL();
          print(downloadUrl + " uploadtostorage");
        });
      });
    });
  }

// uploadWeb(MediaInfo mediaInfo, String fileName) async {
//   try {
//     String? mimeType = mime(path.basename(mediaInfo.fileName ?? ''));
//
//     // html.File mediaFile =
//     //     new html.File(mediaInfo.data, mediaInfo.fileName, {'type': mimeType});
//     final String? extension = extensionFromMime(mimeType!);
//
//     var metadata = SettableMetadata(
//       contentType: mimeType,
//     );
//
//     // Reference storageReference =
//     //     fb.storage().ref(ref).child(fileName + ".$extension");
//     print("cupertino  " +
//         metadata.contentType.toString() +
//         ' ' +
//         mediaInfo.fileName.toString());
//     await FirebaseStorage.instance
//         .ref()
//         .child('books/$fileName')
//         .putBlob(mediaInfo.data, metadata);
//
//     // Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
//     // print("download url $imageUri");
//     // return imageUri;
//   } catch (e) {
//     // print("File Upload Error $e");
//     // return null;
//   }
// }

// static Future<String> uploadImageToFirebaseAndShareDownloadUrl(
//     MediaInfo info, String attribute1, File image) async {
//   String? mimeType = mime(path.basename(info.fileName ?? ""));
//   final extension = extensionFromMime(mimeType!);
//   var metadata = SettableMetadata(
//       contentType: 'image/jpeg',
//       customMetadata: {'picked-file-path': image.path});
//
//   Reference ref = FirebaseStorage.instance.ref().child(
//       "images/$attribute1/images_${DateTime.now().millisecondsSinceEpoch}.${extension}");
//   TaskSnapshot uploadTask = await ref.putBlob(info.data ?? "", metadata);
//   return '';
// }
}
