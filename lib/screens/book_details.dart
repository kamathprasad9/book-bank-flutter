import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//models
import '../models/book.dart';
//providers
import '../providers/books_manager.dart';

class BookDetails extends StatefulWidget {
  final Book bookDetails;

  BookDetails({@required this.bookDetails});

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> rebuild() async {
    await Provider.of<BooksManager>(context, listen: false).getBooksData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Book book = widget.bookDetails;
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: getUrl(book.images),
              builder: (BuildContext context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return Center(child: Icon(Icons.error));
                    }
                    // else if (snapshot.data) {
                    //   return Center(
                    //     child: CircularProgressIndicator(),
                    //   );
                    // }
                    else {
                      print('inside');
                      return snapshot.data.length > 0
                          ? Image.network(snapshot.data[0])
                          : Center(
                              child: CircularProgressIndicator(),
                            );
                    }
                }
              },
            ),
            Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.bookName,
                  style: TextStyle(fontSize: 28),
                ),
                Text(
                  book.authorName,
                  style: TextStyle(fontSize: 24),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future<List<String>> getUrl(List<String> images) async {
    List<String> imagesUrl = [];
    images.forEach((image) async {
      final String downloadURL =
          await FirebaseStorage.instance.ref(image).getDownloadURL();
      imagesUrl.add(downloadURL);
    });

    // print(downloadURL);
    print('returning');
    return imagesUrl;
  }
}
