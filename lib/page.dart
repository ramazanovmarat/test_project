
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'news_detail.dart';
import 'news_model.dart';

final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;



class MyPageDemo extends StatefulWidget {
  const MyPageDemo({Key? key}) : super(key: key);

  @override
  _MyPageDemoState createState() => _MyPageDemoState();
}

class _MyPageDemoState extends State<MyPageDemo> {
  @override
  Widget build(BuildContext context) {
    return MyAppPage();
  }
}

class MyAppPage extends StatefulWidget {
  MyAppPage({Key? key}) : super(key: key);

  @override
  State<MyAppPage> createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {

  Future deviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.brand;
  }

  String? _platformVersion;
  Future initPlatformState() async {
    String? platformVersion;
    try {
      platformVersion = await FlutterSimCountryCode.simCountryCode;
    } on PlatformException {
      platformVersion = 'Failed to get sim country code.';
    }
    if(!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });

  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    deviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<FirebaseRemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context,
            AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
          if(snapshot.hasError) {
            return Center(child: Text('Error'));
          }
          if(snapshot.hasData) {
            if(firebaseRemoteConfig.getString("Url") == '') {
            return MyHomePage(firebaseRemoteConfig: snapshot.requireData);
          } else {
            return MyWebViewPage(rem: snapshot.requireData.getString("Url"));
          }
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

Future<FirebaseRemoteConfig> setupRemoteConfig() async {
  final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
  await firebaseRemoteConfig.fetch();
  await firebaseRemoteConfig.activate();
  print(firebaseRemoteConfig.getString("Url"));
  return firebaseRemoteConfig;
}

class MyHomePage extends AnimatedWidget {
  final FirebaseRemoteConfig firebaseRemoteConfig;

  const MyHomePage({super.key, required this.firebaseRemoteConfig})
      : super(listenable: firebaseRemoteConfig);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delta'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            itemCount: news.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          NewsDetail(sportsNews: news[index],)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image(
                        image: NetworkImage(news[index].image),
                        width: 180,
                      ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(news[index].title,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 10),
                                Text(news[index].description,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class MyWebViewPage extends StatefulWidget {
  final String rem;
  MyWebViewPage({super.key,required this.rem});

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  WebViewController? _controller;

  FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller!.canGoBack()) {
          _controller!.goBack();
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WebViewDelta'),
        ),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
          },
          initialUrl: widget.rem,
        ),
      ),
    );
  }
}
