import 'package:flutter/material.dart';
import 'package:qrapp/pages/CameraScan.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: RaisedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CameraScan()));
            },
            child: Text("Scan"),
          ),
        ),
      ),
    );
  }
}
