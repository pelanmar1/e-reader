import 'package:flutter/material.dart';
import 'library_item.dart';
import "models/book.dart";
import "providers/library.dart";
import "package:provider/provider.dart";
import "preview_screen.dart";
import "package:flutter_document_picker/flutter_document_picker.dart";

class LibraryScreen extends StatefulWidget {
  LibraryScreen({Key key}) : super(key: key);

  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Book> _books = [];

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      setState(() {
        _books = Provider.of<Library>(context).books;
      });
    });
    super.initState();
  }

  // void addBookToLibrary() async {
  //   Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage,PermissionGroup.mediaLibrary]);
  //   print(permissions);
  //   var filePath = await FilePicker.getFilePath(
  //       type: FileType.CUSTOM, fileExtension: 'epub');

  //   if (filePath == null) {
  //     print("File not found.");
  //     return;
  //   }
  //   Book newBook = await EpubHandler.createBook(filePath);
  //   if (newBook == null) {
  //     return;
  //   }
  //   Provider.of<Library>(context, listen: false).addBook(newBook);
  // }

  void addBookToLibrary() async {
    FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
      allowedFileExtensions: ['txt'],
    );
    final filePath = await FlutterDocumentPicker.openDocument(params: params);

    if (filePath == null) {
      print("File not found.");
      return;
    }
    
    final bookTitle = await _displayDialog(context);
    if (bookTitle== null){
      return;
    }
    Book newBook = Book(filePath, bookTitle);
    if (newBook == null) {
      return;
    }
    Provider.of<Library>(context, listen: false).addBook(newBook);
  }

  Future<String> _displayDialog(BuildContext context) async {
    TextEditingController textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Book Title'),
            content: TextField(
              controller: textFieldController,
              decoration: InputDecoration(hintText: "Enter a title for this book"),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              FlatButton(
                child: new Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(textFieldController.value.text);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addBookToLibrary(),
          )
        ],
      ),
      body: Container(
        child: Consumer<Library>(builder: (ctx, lib, chld) {
          this._books = lib.books;
          return _books.isEmpty
              ? Center(
                  child: Text(
                      "Library is empty. Add a TXT file to start reading!"))
              : ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (ctx, idx) => GestureDetector(
                    child: LibraryItem(
                      _books[idx],
                    ),
                    onTap: () {
                      Provider.of<Library>(context, listen: false).currentBook =
                          _books[idx];
                      Navigator.pushNamed(context, PreviewScreen.routeName,
                          arguments: {"book": _books[idx]});
                    },
                  ),
                );
        }),
      ),
    );
  }
}
