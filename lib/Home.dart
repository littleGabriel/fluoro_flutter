import 'dart:convert';

import 'package:fluoro/HomeCategoryImages.dart';
import 'package:fluoro/common/Global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.loginResult});
  final Map? loginResult;

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int currentPageIndex = 0;

  var _categoriesResult = [];
  var _popularResult = {};
  var _newestResult = {};
  var _exploreResult = {};
  List<Widget> popularCardList = [];
  List<Widget> categoriesCardList = [];
  List<Widget> newestCardList = [];

  void _getData() async{
    final categoriesResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories'),
    );
    final popularResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories/1/images'),
    );
    final newestResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories/2/images'),
    );
    final exploreResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories/3/images'),
    );

    if (categoriesResponse.statusCode == 200
        && popularResponse.statusCode == 200
        && newestResponse.statusCode == 200
        && exploreResponse.statusCode == 200) {
      setState(() {
        _categoriesResult = json.decode(categoriesResponse.body);
        _popularResult = json.decode(popularResponse.body);
        _newestResult = json.decode(newestResponse.body);
        _exploreResult = json.decode(exploreResponse.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.getDataFail))
      );
     }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    // Locale locale = Localizations.localeOf(context);

    if (_popularResult.isNotEmpty) {
      for (var item in _popularResult["content"]) {
        popularCardList.add(
          Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) =>
                      //       Photo(rawUrl: rs['urls']['raw'],blurHash: rs['blur_hash'],username: rs['user']['username'],userlink: rs['user']['links']['html'],id: rs['id'])
                      //   ),
                      // );
                    },
                    child: SizedBox(
                      height: 200,
                      width: 150,
                      child: BlurHash(
                        imageFit: BoxFit.cover,
                        curve: Curves.bounceInOut,
                        hash: item["blurHash"],
                        image: item["imageUrl"],
                      ),
                    )
                )
            ),
          )
        );
      }
    }
    if (_categoriesResult.isNotEmpty) {
      for (var item in _categoriesResult.skip(3)) {
        categoriesCardList.add(
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              HomeCategoryImages(categoryId: item["categoryId"], title: item["title"], loginResult: widget.loginResult)
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        width: 120,
                        color: Theme.of(context).colorScheme.primary,
                        child: Stack(
                          children: [
                            item["coverPhotoUrl"] != null ? BlurHash(
                              imageFit: BoxFit.cover,
                              curve: Curves.bounceInOut,
                              hash: item["coverPhotoBlurHash"],
                              image: item["coverPhotoUrl"],
                            ) : const SizedBox(),
                            Center(
                              child: Text(
                                // locale.languageCode == "zh" ?
                                item['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  )
              ),
            )
        );
      }
    }
    if (_newestResult.isNotEmpty) {
      for (var item in _newestResult["content"]) {
        newestCardList.add(
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) =>
                        //       Photo(rawUrl: rs['urls']['raw'],blurHash: rs['blur_hash'],username: rs['user']['username'],userlink: rs['user']['links']['html'],id: rs['id'])
                        //   ),
                        // );
                      },
                      child: SizedBox(
                        height: 200,
                        width: 150,
                        child: BlurHash(
                          imageFit: BoxFit.cover,
                          curve: Curves.bounceInOut,
                          hash: item["blurHash"],
                          image: item["imageUrl"],
                        ),
                      )
                  )
              ),
            )
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.upload),
            icon: Icon(Icons.upload_outlined),
            label: 'Upload',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_2_outlined),
            label: 'Account',
          ),
        ],
      ),
      body: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(AppLocalizations.of(context)!.popular),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                            HomeCategoryImages(categoryId: 1, title: AppLocalizations.of(context)!.popular, loginResult: widget.loginResult)
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward))
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: popularCardList,
                ),
              ),

              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                    child: Text(AppLocalizations.of(context)!.categories),
                  ),
                  // IconButton(
                  //     onPressed: () {},
                  //     icon: const Icon(Icons.arrow_forward)
                  // )
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoriesCardList,
                ),
              ),

              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(AppLocalizations.of(context)!.newest),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              HomeCategoryImages(categoryId: 2, title: AppLocalizations.of(context)!.newest, loginResult: widget.loginResult)
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward))
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: newestCardList,
                ),
              ),

            ],
          ),
        ),
        Container(
          color: Colors.red,
        ),
        Container(
          color: Colors.blue,
        ),
        Container(
          color: Colors.amber,
        )
      ][currentPageIndex]
    );
  }
}
