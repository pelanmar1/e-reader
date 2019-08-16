import 'package:flutter/material.dart';
import "../models/book.dart";
import "package:shared_preferences/shared_preferences.dart";


class Library with ChangeNotifier {
  List<Book> _books = [];

  Book _currentBook;

  List<Book> get books {
    return _books;
  }

  void getSavedBooks() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.containsKey("savedBooks");

  }



  void addBook(Book newBook) {
    final existingBook = _books.firstWhere((item) => item.filePath == newBook.filePath,
        orElse: () => null);
    if (existingBook == null) {
      _books.add(newBook);
      notifyListeners();
    }
  }

  set currentBook(Book currentBook){
    this._currentBook = currentBook;
  }

  get currentBook{
    return this._currentBook;
  }

}
