import 'package:flutter/material.dart';
import "models/book.dart";

class LibraryItem extends StatelessWidget {
  final Book book;
  LibraryItem(this.book);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      width: deviceWidth * .40,
      height: 400,
      child: Card(
        elevation: 15,
        margin: EdgeInsets.symmetric(
          horizontal: 100,
          vertical: 50,
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment. center,
          child: Text(
            book.title,
            style: TextStyle(
              fontSize: 40,
            ),
          ),
        ),
      ),
    );
  }
}
