import 'package:book_bank/providers/authentication_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//models
import '../models/book.dart';

//providers
import '../providers/books_manager.dart';

//screens
import '../screens/book_details.dart';

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

  getEmail() async {
    print(await Provider.of<AuthenticationManager>(context, listen: false)
            .getEmail() +
        "getEmail");
  }

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(fontSize: 15);
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: FutureBuilder(
        future:
            Provider.of<BooksManager>(context, listen: false).getBooksData(),
        builder: (context, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: CircularProgressIndicator(),
              ),
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
                                BoxConstraints(minHeight: constraint.minHeight),
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
              return books.length == 0
                  ? Center(child: Text('No books'))
                  : RefreshIndicator(
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
                            print(book.image);
                            Future<String> imageUrl = getUrl(book.image);
                            print("toast $imageUrl");
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BookDetails(bookDetails: book)));
                              },
                              child: Container(
                                  child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    height: 100,
                                    child: imageUrl != null
                                        ? FutureBuilder(
                                            future: getUrl(book.image),
                                            builder: (BuildContext context,
                                                snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  return SizedBox(
                                                    height: 100,
                                                    width: 78,
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                  );
                                                default:
                                                  if (snapshot.hasError)
                                                    return Center(
                                                        child:
                                                            Icon(Icons.error));
                                                  else
                                                    return snapshot.data != null
                                                        ? Image.network(
                                                            snapshot.data.toString())
                                                        : SizedBox(
                                                            height: 100,
                                                            width: 78,
                                                            child: Center(
                                                                child:
                                                                    CircularProgressIndicator()),
                                                          );
                                              }
                                            },
                                          )
                                        : Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.bookName,
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        "Author: " + book.authorName,
                                        style: textStyle,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "MRP: Rs. " + book.mrp,
                                            style: textStyle,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "|",
                                            style: textStyle,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              book.percentOfMRP != '0'
                                                  ? "User Price: Rs. " +
                                                      (double.parse(book
                                                                  .percentOfMRP) *
                                                              double.parse(
                                                                  book.mrp) /
                                                              100)
                                                          .round()
                                                          .toString()
                                                  : "Available for free!",
                                              style: textStyle.copyWith(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            book.area + ", ",
                                            style: textStyle,
                                          ),
                                          Text(
                                            book.city,
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        DateFormat.yMMMd().format(
                                            DateTime.parse(
                                                book.dateOfAdvertisement)),
                                        style: textStyle.copyWith(
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            );
                          }),
                    );
            });
          }
        },
      ),
    );
  }

  Future<String> getUrl(String image) async {
    // print("posi: $image");
    final String downloadURL =
        await FirebaseStorage.instance.ref("books/$image").getDownloadURL();
    // print(downloadURL);
    return downloadURL;
  }
}
