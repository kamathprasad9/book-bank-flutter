import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//models
import '../models/book.dart';
//providers
import '../providers/books_manager.dart';

class BrowseBooks extends StatefulWidget {
  @override
  _BrowseBooksState createState() => _BrowseBooksState();
}

class _BrowseBooksState extends State<BrowseBooks> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> rebuild() async {
    await Provider.of<BooksManager>(context, listen: false).getBooksData();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: FutureBuilder(
        future:
            Provider.of<BooksManager>(context, listen: false).getBooksData(),
        builder: (context, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapShot.error != null) {
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: rebuild,
              child: dataSnapShot.error.toString().contains("SocketException")
                  ? Container(
                      child: Text('No Internet'),
                    )
                  : LayoutBuilder(
                      builder: (context, constraint) {
                        return SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: constraint.maxHeight),
                            child: IntrinsicHeight(
                              child: Container(
                                child: Center(
                                  child: Text(
                                    "${dataSnapShot.error.toString()}",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            );
          } else {
            return Consumer<BooksManager>(builder: (context, booksData, child) {
              List<Book> books = booksData.books;
              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: rebuild,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: books != null
                        ? books.length > 0
                            ? books.length
                            : 0
                        : 0,
                    itemBuilder: (context, index) {
                      Book book = books[index];
                      print(book.images);
                      Future<String> imageUrl = getUrl(book.images[0]);
                      print("toast $imageUrl");
                      return Container(
                          child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            height: 100,
                            child: imageUrl != null
                                ? FutureBuilder(
                                    future: getUrl(book.images[0]),
                                    builder: (BuildContext context, snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        default:
                                          if (snapshot.hasError)
                                            return Center(
                                                child: Icon(Icons.error));
                                          else
                                            return Image.network(snapshot.data);
                                      }
                                    },
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book.bookName),
                              Text("Author: " + book.authorName),
                              Row(
                                children: [
                                  Text("MRP: Rs. " + book.mrp),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("|"),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(book.percentOfMRP != '0'
                                      ? "User Price: Rs. " +
                                          (double.parse(book.percentOfMRP) *
                                                  double.parse(book.mrp))
                                              .round()
                                              .toString()
                                      : "Available for free!"),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.pin_drop_outlined,
                                    color: Colors.grey,
                                  ),
                                  Text(book.area + ", "),
                                  Text(book.city),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ));
                    }),
              );
            });
          }
        },
      ),
    );
  }

  Future<String> getUrl(String image) async {
    final String downloadURL =
        await FirebaseStorage.instance.ref(image).getDownloadURL();
    // print(downloadURL);
    return downloadURL;
  }
}
