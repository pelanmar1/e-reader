import 'package:flutter/material.dart';
import "package:draggable_scrollbar/draggable_scrollbar.dart";
import "reader_screen.dart";
import 'models/preferences.dart';
import "providers/library.dart";
import "package:provider/provider.dart";
import 'package:indexed_list_view/indexed_list_view.dart';

class TextScrollView extends StatefulWidget {
  final _text;
  int bookmark;

  TextScrollView(this._text, {this.bookmark});

  @override
  _TextScrollViewState createState() => _TextScrollViewState();
}

class _TextScrollViewState extends State<TextScrollView> {
  IndexedScrollController _controller;

  int bookmarkPosition;
  @override
  void initState() {
    if (widget.bookmark != null) {
      setState(() {
        bookmarkPosition = widget.bookmark;
      });
    }
    if (bookmarkPosition != null) {
      _controller = IndexedScrollController(
        initialIndex: bookmarkPosition-1,
      );
    } else {
      _controller = IndexedScrollController();
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Future.delayed(Duration.zero).then((val) async {
    //   final String bookFilePath =
    //       Provider.of<Library>(context).currentBook.filePath;
    //   if (bookFilePath != null) {
    //     int bookmark = await Preferences.loadBookmark(bookFilePath);
    //     setState(() {
    //       bookmarkPosition = bookmark;
    //     });
    //   }
    // });
    // if (bookmarkPosition != null) {
    //   _controller.jumpToIndex(bookmarkPosition);
    // }
    super.didChangeDependencies();
  }

  List<String> get textLines {
    List<String> validLines = widget._text.split("\n");
    validLines = validLines.where((line) => line.length > 1).toList();
    return validLines;
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = (MediaQuery.of(context).size.height -
        Scaffold.of(context).appBarMaxHeight);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: availableHeight,
      child: IndexedListView.builder(
        // shrinkWrap: true,
        // itemExtent: _itemExtent,
        itemCount: textLines.length,
        controller: _controller,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              child: Container(
                color: bookmarkPosition == index + 1
                    ? Colors.lightBlue
                    : Colors.white,
                padding: EdgeInsets.all(8),
                child: Text(
                  textLines[index],
                  style: TextStyle(
                      fontSize: 16,
                      color: bookmarkPosition == index + 1
                          ? Colors.white
                          : Colors.black),
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(ReaderScreen.routeName, arguments: {
                "offset": index,
                "textLines":
                    textLines.getRange(index, textLines.length - 1).toList()
              });
            },
          );
        },
      ),
    );
  }
}
