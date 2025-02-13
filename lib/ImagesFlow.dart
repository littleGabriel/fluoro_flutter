import 'dart:convert';

import 'package:fluoro/common/Global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImagesFlow extends StatefulWidget {
  const ImagesFlow({super.key, required this.categoryId});
  final String categoryId;

  @override
  State<ImagesFlow> createState() => ImagesFlowState();
}

class ImagesFlowState extends State<ImagesFlow> {
  int currentPageIndex = 0;

  var _categorizeImagesResult = {};
  List<Widget> popularCardList = [];

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
    if (_categorizeImagesResult.isNotEmpty) {
      for (var item in _categorizeImagesResult["content"]) {
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

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appName),
          automaticallyImplyLeading: false,
        ),
        body: GridView.count(
            padding: const EdgeInsets.all(4),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            crossAxisCount: 2,
            children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: const Text("He'd have you all unravel at the"),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[200],
                  child: const Text('Heed not the rabble'),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[300],
                  child: const Text('Sound of screams but the'),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[400],
                  child: const Text('Who scream'),
                ),
            ]
    ));

  }
}
