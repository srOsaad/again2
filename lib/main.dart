import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NfcScanScreen(), 
    );
  }
}


class NfcScanScreen extends StatefulWidget {
  @override
  _NfcScanScreenState createState() => _NfcScanScreenState();
}

class _NfcScanScreenState extends State<NfcScanScreen> {
  CardState _cardState = CardState.WaitingForTap;  
  String tagId="", error="";
  @override
  void initState() {
    super.initState();
    startScan();
  }

  Future<void> startScan() async {
    bool nfcSupported = await FlutterNfcKit.nfcAvailability != NFCAvailability.not_supported;
    if (!nfcSupported) {
      setState(() {
        _cardState = CardState.NoNfcSupport;
      });
      return;
    }

    bool nfcEnabled = await FlutterNfcKit.nfcAvailability == NFCAvailability.available;
    if (!nfcEnabled) {
      setState(() {
        _cardState = CardState.NfcDisabled;
      });
      return;
    }

    setState(() {
      _cardState = CardState.WaitingForTap; 
    });

    try {
      NFCTag tag = await FlutterNfcKit.poll();
      
      setState(() {
        _cardState = CardState.Scanned;
        tagId = tag.id;
      });

      print("NFC Tag ID: $tagId");
    } catch (e) {
      setState(() {
        _cardState = CardState.Error;
        error = e.toString();
      }); 
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    FlutterNfcKit.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_cardState == CardState.NoNfcSupport)
              Text("No NFC support on this device."),
            if (_cardState == CardState.NfcDisabled)
              Text("Please enable NFC."),
            if (_cardState == CardState.WaitingForTap)
              Text("Tap an NFC tag to scan."),
            if (_cardState == CardState.Scanned)
              Text("NFC tag scanned successfully!"),
            if (_cardState == CardState.Error)
              Text("An error occurred during scanning."),
              Text("Nfc tag id: ${tagId==""?"I am a disco dancer" : tagId}"),
              Text("foul error: ${error}"),
          ],
        ),
      ),
    );
  }
}

enum CardState {
  NoNfcSupport,
  NfcDisabled,
  WaitingForTap,
  Scanned,
  Error,
}
