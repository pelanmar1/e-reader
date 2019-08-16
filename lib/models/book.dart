
class Book {
  final String _filePath;
  final String _title;
  Book(this._filePath, this._title);

  String get filePath {
    return _filePath;
  }

  String get title{
    return _title;
  }
}