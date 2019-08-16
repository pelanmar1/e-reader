import 'package:flutter/material.dart';
import "settings_screen.dart";
import "models/preferences.dart";
import "providers/library.dart";
import "package:provider/provider.dart";

enum ColorTheme { LIGHT, DARK, SEPIA }

class ReaderScreen extends StatefulWidget {
  static const routeName = "reader-screen";
  Map<String, dynamic> _arguments;
  List<String> _textLines;
  int _offset;

  ReaderScreen(arguments) {
    this._arguments = arguments;
    this._textLines = _arguments["textLines"];
    this._offset = _arguments["offset"];
  }
  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with TickerProviderStateMixin {
  Animation<Offset> _animation;
  AnimationController _controller;
  int currentLine = 0;
  int speed = 200;
  bool isRunning = false;
  String fontFamily;
  double fontSize;
  ColorTheme colorTheme = ColorTheme.LIGHT;
  int lastBookmark;

  get colorThemeColors {
    switch (colorTheme) {
      case ColorTheme.DARK:
        return {"textColor": Colors.white, "backgroundColor": Colors.black};
      case ColorTheme.LIGHT:
        return {"textColor": Colors.black, "backgroundColor": Colors.white};
      case ColorTheme.SEPIA:
        return {
          "textColor": Color.fromRGBO(93, 66, 50, 1),
          "backgroundColor": Color.fromRGBO(231, 222, 199, 1)
        };
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  loadSavedPrefs() async {
    Map preferences = await Preferences.loadPreferences();
    if (preferences != null) {
      setState(() {
        colorTheme = ColorTheme.values[preferences["colorTheme"]];
        speed = int.parse(preferences["readingSpeed"]);
        fontFamily = preferences["fontFamily"];
        fontSize = double.parse(preferences["fontSize"]);
      });
      restartAnimation();
    }
  }

  void restartAnimation() {
    final time = calcDuration(words[currentLine], speed);
    _controller = AnimationController(
      vsync: this,
      duration: time,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        increaseLine();
        restartAnimation();
        Future.delayed(Duration(milliseconds: 500));
        _controller.forward();
      }
    });
    _animation = Tween<Offset>(begin: Offset(0, 0), end: Offset(-0.8, 0))
        .animate(_controller);
  }

  @override
  void didChangeDependencies() async {
    await loadSavedPrefs();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((val) async {
      await loadSavedPrefs();
      String bookFilePath =
          Provider.of<Library>(context, listen: false).currentBook.filePath;
      int currentBookmark = await Preferences.loadBookmark(bookFilePath);
      if (checkIfBookmark(currentBookmark)) {
        setState(() {
          lastBookmark = currentBookmark;
        });
      }
    });
    restartAnimation();
    super.initState();
  }

  List<String> get words {
    var text = widget._textLines;
    return text;
  }

  int get textOffset {
    return widget._offset;
  }

  Duration calcDuration(text, speedWpm) {
    return Duration(seconds: (text.split(" ").length / speedWpm * 60).floor());
  }

  bool checkIfBookmark(int bookmarkOffset) {
    return textOffset + this.currentLine + 1 == bookmarkOffset;
  }

  Future<void> saveReadingProgress() async {
    int bookmarkOffset = textOffset + this.currentLine + 1;
    String bookFilePath =
        Provider.of<Library>(context, listen: false).currentBook.filePath;
    if (bookFilePath != null) {
      Preferences.saveBookmark(bookFilePath, bookmarkOffset);
      setState(() {
        lastBookmark = bookmarkOffset;
      });
      print("Saving $bookmarkOffset");
    }
  }

  void increaseLine() async {
    setState(() {
      this.currentLine += 1;
    });
  }

  _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < screenWidth / 2) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  _onTapUp(TapUpDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    print("tap up " + x.toString() + ", " + y.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: FittedBox(child: Text("Reader")),
          actions: <Widget>[
            IconButton(
              icon: Icon(lastBookmark == textOffset + this.currentLine + 1
                  ? Icons.bookmark
                  : Icons.bookmark_border),
              onPressed: () async {
                await saveReadingProgress();
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(SettingsScreen.routeName);
              },
            )
          ],
        ),
        body: GestureDetector(
            onTapDown: (TapDownDetails details) => _onTapDown(details),
            onTapUp: (details) {
              _controller.stop();
            },
            child: Container(
              color: colorThemeColors["backgroundColor"],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SlideTransition(
                        position: _animation,
                        child: Container(
                          margin: EdgeInsets.only(left: 30),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  UnconstrainedBox(
                                                                      child: Text(
                                      words[currentLine],
                                      style: TextStyle(
                                          fontSize:
                                              fontSize == null ? 100 : fontSize,
                                          fontFamily: fontFamily == null
                                              ? "Roboto"
                                              : fontFamily,
                                          color: colorThemeColors["textColor"]),
                                      softWrap: false,
                                      // overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )));
  }
}
