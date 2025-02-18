import 'dart:convert';
import 'dart:io';

import 'package:fluoro/Home.dart';
import 'package:fluoro/common/Global.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'Auth/Login.dart';
import 'Auth/Register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=> DataProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const WelcomePage(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      )
    );
  }
}

class DataProvider extends ChangeNotifier {

}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePagePageState();
}

class _WelcomePagePageState extends State<WelcomePage> {
  var appCoverResult = {};

  void getAppCover() async {
    final response = await http.Client().get(Uri.parse(
        "${Global.host}/api/public/categories/3/images?per_page=1"));
    if (response.statusCode == HttpStatus.ok) {
      setState(() {
        appCoverResult = json.decode(response.body);
      });
    }
  }

  void checkSignStatus() async {
    // const storage = FlutterSecureStorage();
    // final loginResult = await storage.read(key: 'loginResult');
    //
    // if(loginResult != null) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) =>
    //         Home(loginResult: json.decode(loginResult))
    //     ),
    //   );
    // }
  }

  @override
  void initState() {
    super.initState();
    checkSignStatus();
    getAppCover();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                const Home()
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.skip,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                // begin: Alignment.bottomCenter,
                // end: Alignment.center,
                stops: const [0,1],
                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.8)],
              ).createShader(bounds);
            },
            blendMode: BlendMode.hardLight,
            child: appCoverResult.isNotEmpty ? BlurHash(
              imageFit: BoxFit.cover,
              curve: Curves.bounceInOut,
              hash: appCoverResult["content"][0]["blurHash"],
              image: appCoverResult["content"][0]["imageUrl"],
            ): const SizedBox()
          ),
          Positioned(
            left: 24.0,
            top: 240,
            child: Text(
              AppLocalizations.of(context)!.welcomeTo,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              // TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            left: 24.0,
            top: 320,
            child: Text(
              AppLocalizations.of(context)!.appName,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              // TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
          Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  FilledButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      const Register()
                                  ),
                                );
                              },
                              child: SizedBox(
                                  width: 120,
                                  height: 48,
                                  child: Center(
                                    child: Text(AppLocalizations.of(context)!.signUp),
                                  ),
                              )
                          ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  const Login()
                              ),
                            );
                          },
                          child: Text(AppLocalizations.of(context)!.capitalizedSignIn)
                      )
                    ],
                  )
                ],
              )
          ),
          Positioned(
              bottom: 0,
              right: 10,
              child: Row(
                children: [
                  appCoverResult.isNotEmpty ? Text(
                    "Image from ${appCoverResult["content"][0]["user"]["username"]}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ) : const SizedBox(),
                ],
              )

          ),
        ],
      ),
    );
  }
}
