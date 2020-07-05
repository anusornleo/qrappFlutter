import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as Http;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrapp/pages/ResultPage.dart';
import 'package:location/location.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CameraScan extends StatefulWidget {
  @override
  _CameraScanState createState() => _CameraScanState();
}

class _CameraScanState extends State<CameraScan> {
  ScanResult scanResult;

  final _flashOnController = TextEditingController(text: "Flash on");
  final _flashOffController = TextEditingController(text: "Flash off");
  final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  Map<String, double> locationMe = {"lat": 0, "lon": 0};

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Future scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": _cancelController.text,
          "flash_on": _flashOnController.text,
          "flash_off": _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);

//      setState(() => scanResult = result);
      if (result.type?.toString() != 'Cancelled') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ResultPage(
                      locationMe: locationMe,
                      result: result.rawContent ?? "",
                    )));
      }
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  Future<void> getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      locationMe = {
        "lat": _locationData.latitude,
        "lon": _locationData.longitude
      };
    });
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product'),
        actions: <Widget>[
          IconButton(
            icon: FaIcon(FontAwesomeIcons.qrcode),
            tooltip: "Scan",
            onPressed: scan,
          )
        ],
      ),
      body: FutureBuilder(
        future: getDataProduct(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _listItem(snapshot.data);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _listItem(List<dynamic> data) {
    return Container(
//      padding: EdgeInsets.all(16),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 0,
          childAspectRatio: 2 / 3,
        ),
        itemBuilder: (BuildContext context, int index) {
          int id = data[index]["id"];
          String image = data[index]["image"];
          String name = data[index]["name"];
          String price = data[index]["price"].toString();
          return CardProduct(
            image: image,
            name: name,
            price: price,
            index: index,
            locationMe: locationMe,
            id:id
          );
        },
      ),
    );
  }

  Future<dynamic> getDataProduct() async {
    var url = "http://10.0.2.2:8000/product/";
    var response = await Http.get(
      url,
      headers: {"content-type": "application/json"},
    );
    String source = Utf8Decoder().convert(response.bodyBytes);
    List<dynamic> data = json.decode(source);
    return data;
  }
}

class CardProduct extends StatefulWidget {
  CardProduct({
    Key key,
    @required this.image,
    @required this.name,
    @required this.price,
    @required this.index,
    this.locationMe,
    this.id
  }) : super(key: key);

  final String image;
  final String name;
  final String price;
  final int index;
  final Map<String, double> locationMe;
  final int id;

  @override
  _CardProductState createState() => _CardProductState();
}

class _CardProductState extends State<CardProduct> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(widget.locationMe);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResultPage(
                  locationMe: widget.locationMe,
                  result: widget.id.toString(),
                )));
      },
      child: Container(
        margin: EdgeInsets.only(
            left: widget.index % 2 == 0 ? 16 : 0,
            right: widget.index % 2 != 0 ? 16 : 0,
            top: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 3,
                  color: Colors.grey.withOpacity(.3),
                  blurRadius: 10)
            ]),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    image: DecorationImage(image: NetworkImage(widget.image))),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name),
                    Text(widget.price),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment(0.7, 0),
                child: Text(
                  widget.price + " ฿",
                  style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
