import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:qrapp/widgets/CardLocation.dart';

class ResultPage extends StatefulWidget {
  final String result;
  final Map<String, double> locationMe;

  const ResultPage({this.result = 'not found', this.locationMe});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool dataFromStock = true;

  @override
  Widget build(BuildContext context) {
//    getDataDistance().then((value) => print(value));

    return Scaffold(
        body: SingleChildScrollView(
      child: SafeArea(
        child: FutureBuilder(
          future: getDataDistance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildBody(context, snapshot.data);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    ));
  }

  Future<dynamic> getDataDistance() async {
    var url = "http://10.0.2.2:8000/stock/" + widget.result + "/byLocation/";
    Map<String, dynamic> location = {"lat": 13.847850, "lon": 100.540943};
    final body = jsonEncode(location);
    var response = await Http.post(
      url,
      body: body,
      headers: {"content-type": "application/json"},
    );
    String source = Utf8Decoder().convert(response.bodyBytes);
    if (source == "[]") {
      var url = "http://10.0.2.2:8000/product/" + widget.result;
      var response = await Http.get(
        url,
        headers: {"content-type": "application/json"},
      );
      source = '[{"stock":{"product":' +
          Utf8Decoder().convert(response.bodyBytes) +
          '}}]';
      setState(() {
        dataFromStock = false;
      });
    }
    List<dynamic> data = json.decode(source);
    return data;
  }

  Widget _buildBody(BuildContext context, List<dynamic> snapshot) {
    String image = snapshot[0]["stock"]["product"]["image"];
    String productName = snapshot[0]["stock"]["product"]["name"];
    String productDetail = snapshot[0]["stock"]["product"]["detail"];
    String productPrice =
        snapshot[0]["stock"]["product"]["price"].toStringAsFixed(2);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            image,
            width: double.infinity,
            height: 300,
            fit: BoxFit.contain,
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  productDetail,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "$productPrice ฿",
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 12,
                ),
                Center(
                  child: Text(
                    dataFromStock?"คุณสามารถซื้อได้ที่":"ผลิตภัณฑ์นี้ยังไม่วางจำหน่าย",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
                _listLocation(context, snapshot)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _listLocation(BuildContext context, List<dynamic> snapshot) {
    return Container(
      child: dataFromStock
          ? ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String distance =
                    snapshot[index]["distance"].toStringAsFixed(2);
                String quantity =
                    snapshot[index]["stock"]["quantity"].toString();
                String name = snapshot[index]["stock"]["location"]["name"];
                String image = snapshot[index]["stock"]["location"]["image"];
                return CardLocation(
                    image: image,
                    name: name,
                    quantity: quantity,
                    distance: distance);
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 16,
                );
              },
              itemCount: snapshot.length,
            )
          : Center(),
    );
  }
}
