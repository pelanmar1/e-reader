import 'package:flutter/material.dart';

class Reader extends StatefulWidget {
  final List<String> _textLines;

  Reader(this._textLines);

  _ReaderState createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  var _currentWordId = 0;
  var _buttonPressed = false;
  bool _loopActive = false;
  int _speedIdx = 1; // 300 wps
  List<int> _speedList = [200, 300, 400, 500, 600, 1000];

  List<String> get words {
    var text = widget._textLines.join("\n");
    // text = text.replaceAll(new RegExp(r'[.,;]+'), "");
    text = text.replaceAll("\n", "");
    return text.split(" ");
  }

  int get speed {
    return _speedList[_speedIdx];
  }

  void _setSpeed(newSpeedPerc) {
    final speedCount = _speedList.length;
    var newSpeedIdx = 0;
    for (var i = 0; i < speedCount; i++) {
      if (newSpeedPerc == i / (speedCount - 1)) {
        newSpeedIdx = i;
      }
    }
    setState(() {
      _speedIdx = newSpeedIdx;
    });
  }

  void _increaseCurrentWordIdWhilePressed() async {
    // make sure that only one loop is active
    if (_loopActive) return;

    _loopActive = true;

    while (_buttonPressed) {
      setState(() {
        _currentWordId = (_currentWordId + 1) % words.length;
      });

      // wait a bit
      await Future.delayed(
          Duration(milliseconds: (1000 * 60 / this.speed).round()));
    }

    _loopActive = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Listener(
            onPointerDown: (details) {
              _buttonPressed = true;
              _increaseCurrentWordIdWhilePressed();
            },
            onPointerUp: (details) {
              _buttonPressed = false;
            },
            child: Text(
              words[this._currentWordId],
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
        // Expanded(child: SizedBox()),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 200.0,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Slider(
                    min: 0.0,
                    max: 1.0,
                    divisions: (_speedList.length - 1),
                    label: "${speed.toString()} wps",
                    value: _speedIdx / (_speedList.length - 1),
                    onChanged: (value) => _setSpeed(value)),
              ]),
        )
      ],
    );
  }
}
