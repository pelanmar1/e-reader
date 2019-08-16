import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/preferences.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = "settings";
  SettingsScreen({Key key}) : super(key: key);

  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var colorThemeValue;
  var fontFamilyValue;
  var fontSizeController = TextEditingController();
  var readingSpeedController = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((val) async {
      Map preferences = await Preferences.loadPreferences();
      if (preferences != null) {
        setState(() {
          colorThemeValue = colorThemes[preferences["colorTheme"]];
          fontFamilyValue = preferences["fontFamily"];
          fontSizeController.text = preferences["fontSize"];
          readingSpeedController.text = preferences["readingSpeed"];
        });
      }
    });
    super.initState();
  }

  saveSettings() async {
    Map<String, dynamic> newPrefs = {
      "colorTheme": selectedColorThemeId,
      "fontFamily": fontFamilyValue,
      "fontSize": fontSizeController.text,
      "readingSpeed": readingSpeedController.text
    };
    await Preferences.savePreferences(newPrefs);
  }

  get fonts {
    return Preferences.fonts;
  }

  get colorThemes {
    return ["Light", "Dark", "Sepia"];
  }

  get selectedColorThemeId{
    List themes = colorThemes;
    return themes.indexOf(colorThemeValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await saveSettings();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Card(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Color Theme"),
                    DropdownButton<String>(
                      value: colorThemeValue,
                      onChanged: (String newValue) {
                        setState(() {
                          colorThemeValue = newValue;
                        });
                      },
                      items: colorThemes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Font Family"),
                    DropdownButton<String>(
                      value: fontFamilyValue,
                      onChanged: (String newValue) {
                        setState(() {
                          fontFamilyValue = newValue;
                        });
                      },
                      items:
                          fonts.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontFamily: value),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Font Size"),
                    Container(
                      width: 80,
                      child: TextFormField(
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        controller: fontSizeController,
                        keyboardType: TextInputType.number,
                        validator: (newValue){
                          if(int.parse(newValue)<5 || int.parse(newValue)>150){
                            return "Invalid input";
                          }
                          return null;
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Reading Speed"),
                    Container(
                      width: 80,
                      child: TextField(
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        controller: readingSpeedController,
                        keyboardType: TextInputType.number,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
