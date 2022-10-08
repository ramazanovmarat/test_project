import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Shared {

  static  getPath() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return  storage.getString('key');
  }

  static setPath() async {
    FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
    SharedPreferences storage = await SharedPreferences.getInstance();
    final path = storage.setString('key', firebaseRemoteConfig.getString("url"));
    return path;
  }

}