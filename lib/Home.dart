import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluoro/HomeCategoryImages.dart';
import 'package:fluoro/common/Global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'Auth/Login.dart';

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
  var _exploreResult = {
    "content": []
  };
  List<Widget> popularCardList = [];
  List<Widget> categoriesCardList = [];
  List<Widget> newestCardList = [];
  int exploreImagesPage = 1;
  bool isLoading = false; // 新增标志位

  Map<String, String> authHeaders = {};

  void _getData(bool isNext) async{
    if (isLoading) return; // 如果正在加载，直接返回
    isLoading = true; // 设置为正在加载
    if(isNext) { exploreImagesPage++; }
    else {
      exploreImagesPage = 1;
      setState(() {
        _exploreResult["content"]?.clear();
      });
    }
    if(widget.loginResult!= null) {
      authHeaders = {
        'Authorization': "Bearer ${widget.loginResult?["token"]}",
      };
    }

    final categoriesResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories'),
    );
    final popularResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories/1/images?per_page=6'),
    );
    final newestResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories/2/images?per_page=6'),
    );
    final exploreResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories/3/images?page=$exploreImagesPage'),
        headers: authHeaders
    );

    if (categoriesResponse.statusCode == 200
        && popularResponse.statusCode == 200
        && newestResponse.statusCode == 200
        && exploreResponse.statusCode == 200) {
      setState(() {
        _categoriesResult = json.decode(categoriesResponse.body);
        _popularResult = json.decode(popularResponse.body);
        _newestResult = json.decode(newestResponse.body);
        _exploreResult["content"]?.addAll(json.decode(exploreResponse.body)["content"]);
        print("exploreImagesPage: $exploreImagesPage");
        print("exploreResponse.content: ${json.decode(exploreResponse.body)["content"]}");
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.getDataFail))
      );
     }
    isLoading = false; // 加载完成，重置标志位
  }

  void _toggleLike(bool likeStatus, int imageId) async {
    http.Response? likeResponse;
    if(widget.loginResult!= null) {
      authHeaders = {
        'Content-Type': "application/x-www-form-urlencoded",
        'Authorization': "Bearer ${widget.loginResult?["token"]}",
      };
    }
    if(widget.loginResult == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
        const Login()
        ),
      );
    } else if(likeStatus == true) {
      likeResponse = await http.post(
        Uri.parse('${Global.host}/api/like'),
        headers: authHeaders,
        body: "image_id=$imageId",
      );
      print("likeResponse: ${likeResponse.body}");
    }
    else if(likeStatus == false) {
      likeResponse = await http.delete(
        Uri.parse('${Global.host}/api/like'),
        headers: authHeaders,
        body: "image_id=$imageId",
      );
      print("unlikeResponse: ${likeResponse.body}");
    }

    if (likeResponse != null && likeResponse.statusCode == 200) {
      // 更新当前页面中对应图片的点赞状态
      setState(() {
        for (var item in _exploreResult["content"]!) {
          if (item["imageId"] == imageId) {
            item["liked"] = likeStatus;
            break;
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getData(false);
  }

  @override
  Widget build(BuildContext context) {
    if (_popularResult.isNotEmpty) {
      popularCardList.clear();
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
      categoriesCardList.clear();
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
                        height: 100,
                        width: 160,
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
      newestCardList.clear();
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

        body: Stack(
          children: [
            <Widget>[
              EasyRefresh(
                  onRefresh: () async {
                    _getData(false);
                  },
                  onLoad: () async {
                    _getData(true);
                  },
                  child: SingleChildScrollView(
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

                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                                child: Text(AppLocalizations.of(context)!.explore),
                              ),
                            ],
                          ),
                          _exploreResult.isEmpty ?
                          const SizedBox() :
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              crossAxisCount: 2,
                            ),
                            padding: const EdgeInsets.all(4),
                            itemCount: _exploreResult["content"]?.length,
                            itemBuilder: (context, index) {
                              return buildCategoryCard(context, index);
                            },
                          ),
                        ],
                      )
                  )
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
            ][currentPageIndex],
            if (_exploreResult.isEmpty)
              const Center(
                child: CircularProgressIndicator(),
              )
          ],
        )

    );
  }

  Widget buildCategoryCard(BuildContext context, int index) {
    final item = _exploreResult["content"]?[index];

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          // ...
        },
        child: Stack(
          children: [
            SizedBox(
              child: BlurHash(
                imageFit: BoxFit.cover,
                curve: Curves.bounceInOut,
                hash: item["blurHash"],
                image: item["imageUrl"],
              ),
            ),
            Positioned(
                bottom: 6,
                right: 6,
                child: IconButton(
                    onPressed: () {
                      _toggleLike(!item["liked"], item["imageId"]);

                      // _getData(false);

                      // setState(() {
                      //   item["liked"] = !item["liked"];
                      // });
                    },
                    icon: Icon(item["liked"] ? Icons.favorite : Icons.favorite_outline)
                )
            ),
          ],
        ),
      ),
    );
  }
}
