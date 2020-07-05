import 'package:flutter/material.dart';

class CardLocation extends StatelessWidget {
  const CardLocation({
    Key key,
    @required this.image,
    @required this.name,
    @required this.quantity,
    @required this.distance,
  }) : super(key: key);

  final String image;
  final String name;
  final String quantity;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 3),
                blurRadius: 10,
                spreadRadius: 3,
                color: Colors.grey.withOpacity(.3))
          ]),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                    image: NetworkImage(image), fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 96,
            child: Text(
              name,
              style: TextStyle(fontSize: 22),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 96,
            child: Row(
              children: [
                Text(
                  quantity,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  " left",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 16,
            child: Text(
              "$distance km.",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
