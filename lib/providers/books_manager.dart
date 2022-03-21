import 'package:book_bank/providers/authentication_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

//models
import '../models/book.dart';
import '../models/owner.dart';

class BooksManager with ChangeNotifier {
  late List<Book> _books;

  // ignore: unused_field
  late AuthenticationManager _authenticationManager;

  late Owner? _owner;

  List<Book> get books => _books;

  get length => _books.length;

  get owner => _owner;

  set authenticationManager(AuthenticationManager authenticationManager) {
    _authenticationManager = authenticationManager;
  }

  Future<void> getBooksData() async {
    _books = [];
    try {
      final database = FirebaseDatabase.instance.reference();
      // print("fetch data: $database");
      await database.once().then((DataSnapshot snapshot) {
        // print('Data : ${snapshot.value}');
        if (snapshot.value != null) {
          final extractedData = snapshot.value['booksArray'] as List;
          // print("extracted $extractedData");
          if (extractedData.isNotEmpty) {
            // print(extractedData);
            _books = extractedData
                .map((imageData) => Book.fromJson(imageData))
                .toList();
          }
        } else {
          _books = [];
        }
        notifyListeners();
        return _books;
      });
    } catch (error) {
      throw "no content";
    }
  }

  Future<void> getOwnerInfo(String email) async {
    _owner = null;
    print("/////");
    // print('getAllUsers $email');
    String emailReplaced = email.replaceAll("@", "at").replaceAll(".", "dot");
    // print('getAllUsers $email');
    try {
      await FirebaseDatabase.instance
          .reference()
          .child('usersArray')
          .child(emailReplaced)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          print('usersArray');
          print(snapshot.value);
          final extractedData = snapshot.value;
          // debugPrint("extracted $extractedData");
          print(extractedData.toString() + "list");
          if (extractedData != null) {
            _owner = Owner.fromJson(extractedData);
          }
          print("////${_owner!.name}");
        } else {
          _owner = null;
          print("no users found");
        }
        notifyListeners();
      });
    } catch (e) {
      throw e;
    }
  }

  Future<String> downloadURL(String image) async {
    print("imagesURL $image");
    String downloadURL =
        await FirebaseStorage.instance.ref("books/$image").getDownloadURL();

    print("imagesURL $downloadURL");

    notifyListeners();
    return downloadURL;
  }
}
