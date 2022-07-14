import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_demo/utils/html_parse_util.dart';
import 'package:flutter_html_demo/utils/html_util.dart';
import 'package:flutter_html_demo/utils/table_util.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    var result = {
      "businessType": "",
      "destinationWhName": "USWC Warehouse",
      "isMasterPackage": "N",
      "leave": "A",
      "orderNo": "WI991128340300",
      "packageSerno": "B0400000001069804405",
      "result": [
        {"abcAttribute": "B",
          "itemQty": 0,
          "itemTotalQty": 4,
          "sku": "M010000000004016060",
          "skuQty": 1,
          "skuSpec": "T50-",
          "winitOrderNo": "WI991128340300"
        }],
      "scanKeword": "B0400000001069804405",
      "scanType": "B",
      "status": "PRESORTING_COMPLETED",
      "totalQty": 1,
      "unloadTime": "2022-06-13 19:47"
    };

    var htmlData1 = """
    <div>
        <div>[scanKeword] [scanType]</div>
    </div>
    <div><font color = \"#FF0033\" size='5'>[scanKeword] [scanType]</font></div>
    <table style="width:100%">
      <tr>
		    <th>[result-0-index]</th> 
		    <th>[result-0-barcode]</th> 
		    <th>[result-0-goods]</th> 
		    <th>[result-0-numbers]</th> 
		    <th>[result-0-isOnShelf]</th> 
	    </tr>
      <tr> 
		    <td>[result-1-index]</td> 
		    <td>[result-1-barcode]</td> 
		    <td><font color="#FF0033">[result-1-goods]</font></td> 
		    <td>[result-1-numbers]</td> 
		    <td>[result-1-isOnShelf]</td> 
	    </tr>
  </table>
  </br>
    """;
    //将html模版解析成document
    dom.Document document = htmlparser.parse(htmlData1);
    TableUtil tableUtil = TableUtil(document, result);
    HtmlUtil htmlUtil = HtmlUtil(tableUtil);
    Widget html = htmlUtil.buildHtmlByHtmlModelAndJson(document,result);

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              html,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
