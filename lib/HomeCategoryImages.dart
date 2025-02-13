import 'dart:convert';

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
  var _categorizeImagesResult = {};
  List<Widget> categoryCardList = [];

  void _getData() async{
    final categorizeImagesResponse = await http.get(
      Uri.parse('${Global.host}/api/public/categories/${widget.categoryId}/images'),
    );

    if (categorizeImagesResponse.statusCode == 200) {
      setState(() {
        _categorizeImagesResult = json.decode(categorizeImagesResponse.body);
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
    categoryCardList.clear();
    if (_categorizeImagesResult.isNotEmpty) {
      for (var item in _categorizeImagesResult["content"]) {
        categoryCardList.add(
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
    print("categoryCardList: $categoryCardList");

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: GridView.count(
            padding: const EdgeInsets.all(4),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            crossAxisCount: 2,
            children: categoryCardList,
        ));

  }
}
