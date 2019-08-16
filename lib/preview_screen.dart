import 'dart:convert';
import "package:reader/text_scrollview.dart";
import 'package:flutter/material.dart';
import "dart:io";
import 'package:path_provider/path_provider.dart';
import "providers/library.dart";
import 'package:provider/provider.dart';
import "models/preferences.dart";

class PreviewScreen extends StatefulWidget {
  static const routeName = "preview-screen";

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  int bookmark;
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

@override
void didChangeDependencies() {
  updateBookmark();
  super.didChangeDependencies();
  
}
  Future<String> readFileAsync(String filePath) async {
    final localPath = await _localPath;
    final fileNameLst = filePath.split("/");
    final fileName = fileNameLst.last;
    final File file = new File("$localPath/$fileName");
    final futureContent = await file.readAsString();
    return futureContent;
  }

   updateBookmark() async {
    Future.delayed(Duration.zero).then((val) async {
      final String bookFilePath =
          Provider.of<Library>(context).currentBook.filePath;
      if (bookFilePath != null) {
        
          int tempBookmark = await Preferences.loadBookmark(bookFilePath);
          if(tempBookmark!=null){
            setState(() {
              bookmark=tempBookmark;
            });
          }
      }
    });
  }

  
  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final currentBook = routeArgs["book"];

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text(currentBook.title)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () async{
              await updateBookmark();
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          FutureBuilder(
            future: readFileAsync(currentBook.filePath),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (bookmark != null) {
                  return TextScrollView(
                    snapshot.data,
                    bookmark: bookmark,
                  );
                }
                return TextScrollView(snapshot.data);
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          )
        ],
      ),
    );
  }
}
