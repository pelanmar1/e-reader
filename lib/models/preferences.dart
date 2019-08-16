import "package:shared_preferences/shared_preferences.dart";
import 'dart:convert';

class Preferences {
  static get fonts {
    return [
      "Roboto",
      "Playfair_Display",
      "Open_Sans",
      "Montserrat",
      "Merriweather"
    ];
  }

  static loadPreferences() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (!sp.containsKey("preferences")) {
      return null;
    }
    Map preferencesMap = jsonDecode(sp.getString('preferences'));
    return preferencesMap;
  }

  static savePreferences(Map<String, dynamic> preferencesMap) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String preferencesString = jsonEncode(preferencesMap);
    sp.setString("preferences", preferencesString);
  }

  static saveBookmark(String bookFilePath, int offset) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt("bookmark_$bookFilePath", offset);
  }

  static loadBookmark(String bookFilePath) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.containsKey("bookmark_$bookFilePath")) {
      return sp.getInt("bookmark_$bookFilePath");
    }
    return null;
  }
}
