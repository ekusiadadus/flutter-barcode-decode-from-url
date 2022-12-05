import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_ml_kit/google_ml_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final qrCodeController = TextEditingController();
  Image? image;
  Barcode? result;
  String qrcode = 'Unknown';
  String? qrCodeResult;

  @override
  void initState() {
    super.initState();
    qrCodeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    qrCodeController.dispose();
    super.dispose();
  }

  void _onGetImage() async {
    http.Response response = await http.get(
      Uri.parse(qrCodeController.text),
    );
    setState(() {
      image = Image.memory(response.bodyBytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: qrCodeController,
              decoration: InputDecoration(
                  hintText: 'Enter your QR code URL',
                  labelText: 'QR code URL',
                  border: OutlineInputBorder(),
                  suffixIcon: qrCodeController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            qrCodeController.clear();
                          },
                        )
                      : Container(width: 0)),
            ),
            const SizedBox(height: 20),
            image != null ? image! : Container(),
            const SizedBox(height: 20),
            // Print QRCode's data if QRCode is valid
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onGetImage();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
