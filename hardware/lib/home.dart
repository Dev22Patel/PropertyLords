import 'package:flutter/material.dart';
import 'photo_picker_page.dart';
import 'fingerprint_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to Photo Picker Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PhotoPickerPage()),
                );
              },
              child: Text('Pick a Photo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Fingerprint Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FingerprintPage()),
                );
              },
              child: Text('Fingerprint Authentication'),
            ),
          ],
        ),
      ),
    );
  }
}
