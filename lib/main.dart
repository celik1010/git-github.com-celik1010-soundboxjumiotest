import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(DemoApp());
}

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(
          title: "Mobile SDK Demo App",
        ));
  }
}

class HomePage extends StatefulWidget {
  final String? title;

  HomePage({Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState(title);
}

class _HomePageState extends State<HomePage> {
  final String? title;
  final tokenInputController = TextEditingController();

  _HomePageState(this.title);

  @override
  void dispose() {
    tokenInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: 250.0,
                child: TextFormField(
                  controller: tokenInputController,
                  decoration: InputDecoration(border: UnderlineInputBorder(), labelText: 'Authorization token'),
                ),
              ),
              ElevatedButton(
                child: Text("Start"),
                onPressed: () {
                  _start(tokenInputController.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(String authorizationToken) async {
    bool isSuccess = false;
    var uname = '0Auth2 clients- api key'; //this is my api token in oauth2 clients tab from jumio portal
    var pword = '0Auth2 clients- secret'; //this my api secret in oauth2 clients tab from jumio portal
    var authn = 'Basic ' + base64Encode(utf8.encode('$uname:$pword'));
// var authn = 'Basic $uname:$pword';

    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': authn,
    };

    var data = 'grant_type=client_credentials';

    var url = Uri.parse('https://auth.emea-1.jumio.ai/oauth2/token');
    var res = await http.post(url, headers: headers, body: data);
    if (res.statusCode != 200) throw Exception('http.post error: statusCode= ${res.statusCode}');

    final Map<String, dynamic> response = json.decode(res.body);
    String accessToken = 'Bearer ' + response['access_token'];
    print(accessToken);
    await _logErrors(() async {
      await Jumio.init(accessToken, 'EU');
      final result = await Jumio.start(
          // {
          // "loadingCircleIcon": "#000000",
          // "loadingCirclePlain": "#000000",
          // "loadingCircleGradientStart": "#000000",
          // "loadingCircleGradientEnd": "#000000",
          // "loadingErrorCircleGradientStart": "#000000",
          // "loadingErrorCircleGradientEnd": "#000000",
          // "primaryButtonBackground": {"light": "#FFC0CB", "dark": "#FF1493"}
          // }
          );
      await _showDialogWithMessage("Jumio has completed. Result: $result");
    });
  }

  Future<void> _logErrors(Future<void> Function() block) async {
    try {
      await block();
    } catch (error) {
      await _showDialogWithMessage(error.toString(), "Error");
    }
  }

  Future<void> _showDialogWithMessage(String message, [String title = "Result"]) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(message)),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
