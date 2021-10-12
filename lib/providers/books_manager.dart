import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

//models
import '../models/book.dart';

class BooksManager with ChangeNotifier {
  List<Book> _books;

  List<Book> get books => _books;

  get length => _books.length;

  Future<void> getBooksData() async {
    _books = [];
    try {
      final database = FirebaseDatabase.instance.reference();
      print("fetch data: $database");
      database.once().then((DataSnapshot snapshot) {
        print('Data : ${snapshot.value}');
        if (snapshot.value != null) {
          final extractedData = snapshot.value['booksArray'] as List;
          print("extracted $extractedData");
          if (extractedData != null) {
            print(extractedData);
            extractedData.forEach((imageData) async {
              var imagePaths = imageData["images"];
              List<String> imagesURL = await downloadURLs(imagePaths);
              // print(
              //     "bugDE: ${downloadURLs(imagePaths).then((value) => value)}");
              _books.add(Book.fromJson(imageData, imagesURL));
            });
          }
        } else {
          _books = null;
        }
        notifyListeners();
        return _books;
      });
    } catch (error) {
      throw "no content";
    }
  }

  Future<List<String>> downloadURLs(var images) async {
    List<String> imagesURL = [];
    await images.forEach((image) async {
      String downloadURL =
          await FirebaseStorage.instance.ref(image).getDownloadURL();
      // print(downloadURL);
      imagesURL.add(downloadURL);

      // print("imagesURL $imagesURL");

      notifyListeners();
      return imagesURL;
    });
  }
}