import 'package:flutter/material.dart';

class OurServices extends StatelessWidget {
  const OurServices({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: const <Widget>[
        ListTile(title: Text('List 1')),
        ListTile(title: Text('List 2')),
        ListTile(title: Text('List 3')),
      ],
    );
  }
}
