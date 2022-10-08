
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:test_project/news_detail.dart';
import 'package:test_project/page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'news_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyPageDemo());
}



// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sports News',
//       debugShowCheckedModeBanner: false,
//       home: Home()
//     );
//   }
// }
//
// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);
//
//   @override
//   _HomeState createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<FirebaseRemoteConfig>(
//         future: setupRemoteConfig(),
//         builder: (BuildContext context,
//             AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
//           if(snapshot.hasError) {
//             return Center(child: Text("Error"));
//           }
//           return snapshot.hasData
//               ? MainHome(firebaseRemoteConfig: snapshot.requireData)
//               : Center(child: CircularProgressIndicator());
//         },
//       );
//   }
// }
//
// Future<FirebaseRemoteConfig> setupRemoteConfig() async {
//   final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
//   await firebaseRemoteConfig.fetch();
//   await firebaseRemoteConfig.activate();
//   print(firebaseRemoteConfig.getString("Url"));
//   return firebaseRemoteConfig;
// }
//
// class MainHome extends StatefulWidget {
//   final FirebaseRemoteConfig firebaseRemoteConfig;
//   const MainHome({Key? key, required this.firebaseRemoteConfig}) : super(key: key);
//
//   @override
//   _MainHomeState createState() => _MainHomeState();
// }
//
// class _MainHomeState extends State<MainHome> {
//   WebViewController? _controller;
//
//   final FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
//
//   // проверяем сохранена ли локально ссылка
//   Future checkingPath() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final path = prefs.getString("key");
//     if(path == null) {
//       return loadFire();
//     } else {
//       return WillPopScope(
//         onWillPop: () async {
//           if(await _controller!.canGoBack()){
//             _controller!.goBack();
//           }
//           return false;
//         },
//         child: Scaffold(
//           body: WebView(
//             javascriptMode: JavascriptMode.unrestricted,
//             initialUrl: path,
//           ),
//         ),
//       );
//     }
//   }
//
//   Future loadFire() async {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
//
//     final getUrl = firebaseRemoteConfig.getString("Url");
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//         if (getUrl.isEmpty || androidDeviceInfo.brand == 'google') {
//           return ListView.builder(
//               itemCount: news.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) =>
//                             NewsDetail(sportsNews: news[index],)));
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Image(
//                           image: NetworkImage(news[index].image),
//                           width: 180,
//                         ),
//                         Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 children: [
//                                   Text(news[index].title,
//                                     style: const TextStyle(
//                                         color: Colors.blue,
//                                         fontWeight: FontWeight.bold),
//                                     maxLines: 3,
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(news[index].description,
//                                     maxLines: 4,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ],
//                               ),
//                             )
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               });
//         } else {
//           prefs.setString("key", getUrl);
//           return WillPopScope(
//             child: Scaffold(
//                 body: WebViewPage(rem: '')
//             ),
//             onWillPop: () async {
//               if (await _controller!.canGoBack()) {
//                 _controller!.goBack();
//               }
//               return false;
//             },
//           );
//         }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//     loadFire();
//     checkingPath();
//   }
//
//   String? _platformVersion;
//
//  // проверка наличия симкарты
//   Future<void> initPlatformState() async {
//     String? platformVersion;
//     try {
//       platformVersion = await FlutterSimCountryCode.simCountryCode;
//     } on PlatformException {
//       platformVersion = 'Failed to get sim country code.';
//     }
//     if (!mounted) return;
//
//     setState(() {
//       _platformVersion = platformVersion;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Container(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           child: FutureBuilder(
//               future: checkingPath(),
//               builder: (BuildContext context,
//                   AsyncSnapshot snapshot) {
//                 if(snapshot.hasData) {
//                   return snapshot.data;
//                 }
//                 return const Center(child: CircularProgressIndicator());
//               }),
//         ),
//       ),
//     );
//   }
// }
//
// class WebViewPage extends StatefulWidget {
//   String rem;
//   WebViewPage({super.key,required this.rem});
//
//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }
//
// class _WebViewPageState extends State<WebViewPage> {
//   WebViewController? _controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (await _controller!.canGoBack()) {
//           _controller!.goBack();
//         }
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('WebViewDelta'),
//         ),
//         body: WebView(
//           javascriptMode: JavascriptMode.unrestricted,
//           onWebViewCreated: (WebViewController webViewController) {
//             _controller = webViewController;
//           },
//           initialUrl: widget.rem,
//         ),
//       ),
//     );
//   }
// }
