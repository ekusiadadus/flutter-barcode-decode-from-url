import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  File? imageFile;
  Barcode? result;
  String qrcode = 'Unknown';
  String? qrCodeResult;

  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);

    print("file: $file");
    return file;
  }

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
    final tempfile = await urlToFile(qrCodeController.text);

    setState(() {
      image = Image.memory(response.bodyBytes);
      imageFile = tempfile;
    });
    print("imageFile: ${imageFile!.path}");
    print(imageFile);
  }

  @override
  void _onScan() async {
    final inputImage = InputImage.fromFile(imageFile!);
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    final barcodeScanner = BarcodeScanner(formats: formats);
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;

      // See API reference for complete list of supported types
      switch (type) {
        case BarcodeType.wifi:
          BarcodeWifi barcodeWifi = barcode.value as BarcodeWifi;
          break;
        case BarcodeType.url:
          BarcodeUrl barcodeUrl = barcode.value as BarcodeUrl;
          break;
      }
    }
    print("barcodes: ${barcodes}");

    print("imageFile: ${imageFile!.path}");
    print(imageFile);
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
          _onScan();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
