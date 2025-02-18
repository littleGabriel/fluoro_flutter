import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluoro/Auth/Login.dart';
import 'package:fluoro/common/Global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeCategoryImages extends StatefulWidget {
  const HomeCategoryImages({super.key, required this.categoryId, required this.title, required this.loginResult});
  final int categoryId;
  final String title;
  final Map? loginResult;

  @override
  State<HomeCategoryImages> createState() => HomeCategoryImagesState();
}

class HomeCategoryImagesState extends State<HomeCategoryImages> {
  final _categorizeImagesResult = {
    "content": []
  };
  // List<Widget> categoryCardList = [];
  int categorizeImagesPage = 1;
  Map<String, String> authHeaders = {};

  void _getData(bool isNext) async{
    if(isNext) { categorizeImagesPage++; }
    else {
      categorizeImagesPage = 1;
      setState(() {
        _categorizeImagesResult["content"]?.clear();
        // categoryCardList.clear();
      });
    }
    if(widget.loginResult!= null) {
      authHeaders = {
        // 'Content-Type': "application/json",
        'Authorization': "Bearer ${widget.loginResult?["token"]}",
      };
    }
    print("categorizeImagesPage: $categorizeImagesPage");
    final categorizeImagesResponse = await http.get(
      Uri.parse("${Global.host}/api/public/categories/${widget.categoryId}/images?page=$categorizeImagesPage"),
        headers: authHeaders
    );

    if (categorizeImagesResponse.statusCode == 200) {
      setState(() {
        _categorizeImagesResult["content"]?.addAll(json.decode(categorizeImagesResponse.body)["content"]);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.getDataFail))
      );
    }
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
        for (var item in _categorizeImagesResult["content"]!) {
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
    // categoryCardList.clear();
    // if (_categorizeImagesResult.isEmpty) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // if (_categorizeImagesResult.isNotEmpty) {
    //   print("_categorizeImagesResult.isNotEmpty");
    //   for (var item in _categorizeImagesResult["content"]) {
    //     print(item["liked"]);
    //     categoryCardList.add(
    //         Card(
    //             clipBehavior: Clip.hardEdge,
    //             child: InkWell(
    //                 onTap: () {
    //                   // ...
    //                 },
    //                 child: Stack(
    //                   children: [
    //                     SizedBox(
    //                       // height: 200,
    //                       // width: 150,
    //                       child: BlurHash(
    //                         imageFit: BoxFit.cover,
    //                         curve: Curves.bounceInOut,
    //                         hash: item["blurHash"],
    //                         image: item["imageUrl"],
    //                       ),
    //                     ),
    //                     Positioned(
    //                         bottom: 6,
    //                         right: 6,
    //                         child: IconButton(
    //                             onPressed: () {
    //                               // _like(!item["liked"], item["imageId"]);
    //
    //                               // _getData(false);
    //
    //                               setState(() {
    //                                 item["liked"] = !item["liked"];
    //                               });
    //                             },
    //                             icon: Icon(item["liked"] ? Icons.favorite : Icons.favorite_outline)
    //                         )
    //                     ),
    //                     Positioned(
    //                         bottom: 6,
    //                         right: 30,
    //                         child: Text(item["liked"] ? "true" : "false")
    //                     )
    //                   ],
    //                 )
    //             )
    //         )
    //     );
    //   }
    // }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: EasyRefresh(
          onRefresh: () async {
            _getData(false);
          },
          onLoad: () async {
            _getData(true);
          },
          // child: GridView.count(
          //   padding: const EdgeInsets.all(4),
          //   mainAxisSpacing: 4,
          //   crossAxisSpacing: 4,
          //   crossAxisCount: 2,
          //   children: categoryCardList,
          // ),
          child: _categorizeImagesResult.isEmpty ?
            const Center(child: CircularProgressIndicator()) :
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: 2,
              ),
              padding: const EdgeInsets.all(4),
              itemCount: _categorizeImagesResult["content"]?.length,
              itemBuilder: (context, index) {
                return buildCategoryCard(context, index);
              },
            ),
        )
    );

  }

  // 构建分类卡片
  Widget buildCategoryCard(BuildContext context, int index) {
    final item = _categorizeImagesResult["content"]?[index];

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
