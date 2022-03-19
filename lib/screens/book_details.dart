import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//models
import '../models/book.dart';
import '../models/owner.dart';
//providers
import '../providers/books_manager.dart';

class BookDetails extends StatefulWidget {
  final Book bookDetails;

  BookDetails({required this.bookDetails});

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  Future<void> rebuild() async {
    await Provider.of<BooksManager>(context, listen: false).getBooksData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.blue;
    Book book = widget.bookDetails;
    const double textScaleFactor = 1.35;
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
                      String imageUrl = snapshot.data as String;
                      return imageUrl.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blue, width: 2)),
                              // height: 500,
                              child:
                                  Center(child: Image.network(imageUrl)))
                          : Center(child: CircularProgressIndicator());
                    }
                }
              },
            ),
            Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        book.bookName,
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    Table(
                      columnWidths: {
                        0: FixedColumnWidth(100.0),
                      },
                      children: [
                        TableRow(children: [
                          const Text(
                            "Author",
                            textScaleFactor: textScaleFactor,
                          ),
                          Text(
                            book.authorName,
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(color: textColor),
                          ),
                        ]),
                        TableRow(children: [
                          const Text(
                            "Desc",
                            textScaleFactor: textScaleFactor,
                          ),
                          Text(
                            book.description,
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(color: textColor),
                          ),
                        ]),
                        TableRow(children: [
                          const Text(
                            "Location",
                            textScaleFactor: textScaleFactor,
                          ),
                          Text(
                            book.area + ", " + book.city,
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(color: textColor),
                          ),
                        ]),
                        TableRow(children: [
                          const Text(
                            "MRP",
                            textScaleFactor: textScaleFactor,
                          ),
                          Text(
                            "Rs. " + book.mrp,
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(color: textColor),
                          ),
                        ]),
                        TableRow(children: [
                          const Text(
                            "User Price",
                            textScaleFactor: textScaleFactor,
                          ),
                          Text(
                            book.percentOfMRP != '0'
                                ? "Rs. " +
                                    (double.parse(book.percentOfMRP) *
                                            double.parse(book.mrp) /
                                            100)
                                        .round()
                                        .toString()
                                : "Free!",
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.double,
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          const Text(
                            "Ad. ID",
                            textScaleFactor: textScaleFactor,
                          ),
                          Text(
                            book.id,
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(color: textColor),
                          ),
                        ]),
                        TableRow(children: [
                          const Text(
                            "Date of Ad.",
                            textScaleFactor: textScaleFactor,
                          ),
                          Text(
                            DateFormat.yMMMd().format(
                                DateTime.parse(book.dateOfAdvertisement)),
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(color: textColor),
                          ),
                        ]),
                      ],
                    ),
                    FutureBuilder(
                      future: Provider.of<BooksManager>(context, listen: false)
                          .getOwnerInfo(book.ownerEmail),
                      builder: (BuildContext context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            if (snapshot.hasError) {
                              return Center(child: Icon(Icons.error));
                            } else {
                              return Consumer<BooksManager>(
                                  builder: (context, ownerData, child) {
                                Owner owner = ownerData.owner;
                                return Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.account_circle_rounded),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Owner Details',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                      Table(
                                        columnWidths: {
                                          0: FixedColumnWidth(100.0),
                                        },
                                        children: [
                                          TableRow(children: [
                                            const Text(
                                              "Name",
                                              textScaleFactor: textScaleFactor,
                                            ),
                                            Text(
                                              owner.name,
                                              textScaleFactor: textScaleFactor,
                                              style:
                                                  TextStyle(color: textColor),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "Email",
                                              textScaleFactor: textScaleFactor,
                                            ),
                                            Text(
                                              owner.email,
                                              textScaleFactor: textScaleFactor,
                                              style:
                                                  TextStyle(color: textColor),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "Contact",
                                              textScaleFactor: textScaleFactor,
                                            ),
                                            Text(
                                              owner.contact,
                                              textScaleFactor: textScaleFactor,
                                              style:
                                                  TextStyle(color: textColor),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
                            }
                        }
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
