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
              future: Provider.of<BooksManager>(context, listen: false)
                  .downloadURL(book.image),
              builder: (BuildContext context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return Center(child: Icon(Icons.error));
                    } else {
                      return snapshot.data.length > 0
                          ? Image.network(snapshot.data)
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
}
