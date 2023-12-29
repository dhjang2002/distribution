
// ignore_for_file: unused_import

import 'dart:io';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/mainHome.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' as foundation;

Future <void> _onBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("_onBackgroundHandler() -----------------> ");
  }
  if(message.notification != null) {
    String action = "";
    if(message.data["action"] != null) {
      action = message.data["action"];
    }

    if (kDebugMode) {
      print("title=${message.notification!.title.toString()},\n"
        "body=${message.notification!.body.toString()},\n"
        "action=$action");
    }

    // LocalNotification notification = LocalNotification();
    // notification.initializeNotification();
    // notification.show(
    //     "B>"+message.notification!.title.toString(),
    //     message.notification!.body.toString());
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HttpOverrides.global = MyHttpOverrides();
  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionData()),
      ],
      child: const AppHome(),
    ),
  );
}

class AppHome extends StatelessWidget {
  const AppHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAndroid = true;//foundation.defaultTargetPlatform == foundation.TargetPlatform.android;
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (isAndroid) ? (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.1,
            ),
            child: child!,
          ) : null,
          title: appName,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
                backgroundColor: (modeIsDeveloper) ? Colors.redAccent : Colors.white,
                iconTheme: IconThemeData(
                    color: (modeIsDeveloper) ? Colors.white : Colors.black),
                actionsIconTheme: IconThemeData(
                    color: (modeIsDeveloper) ? Colors.white : Colors.black),
                centerTitle: true,
                elevation: 0.0,
                titleTextStyle: (modeIsDeveloper)
                    ? TextStyle(fontSize: 18,
                        color: Colors.white,
                        fontWeight:
                        FontWeight.normal)
                    : TextStyle(fontSize: 18,
                        color: Colors.black,
                        fontWeight:
                        FontWeight.normal)
            ),

            backgroundColor: Colors.white,
            scaffoldBackgroundColor:Colors.white,
            primarySwatch:  Colors.indigo,
            primaryColor: Colors.red,
          ),

          initialRoute: '/',
          routes: {
            "/"  : (_) => const MainHome(),
          },
        );
      },
    );
  }
}
