import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

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

    String jsonstr = """
 {
   "typeOne":[
      {
        "title":"单品条码",
        "value":"S500036000406844116"
      },{
       "title":"位置",
        "value":"Z10237"
      },{
       "title":"入库单",
        "value":"W1990000000282"
      }
   ],
   "typeTwo":[
      {
        "one":"003274",
        "two":"10",
        "three":"2B",
        "four":"test"
      },{
        "one":"CONTANT",
        "two":"10",
        "three":"2B"
      },
      {
        "one":"003234",
        "two":"5",
        "three":"2B"
      }
   ],
   "typeThree":[
      {
        "index":"序号",
        "barcode":"条码",
        "goods":"商品",
        "numbers":"数量",
        "isOnShelf":"是否上架"
      },{
        "index":"1",
        "barcode":"B04000000000000750",
        "goods":"M*23398",
        "numbers":"5",
        "isOnShelf":"N"
      },{
        "index":"2",
        "barcode":"B04000000000000751",
        "goods":"M*23399",
        "numbers":"4",
        "isOnShelf":"N"
      },{
        "index":"3",
        "barcode":"B04000000000000752",
        "goods":"M*23349",
        "numbers":"10",
        "isOnShelf":"N"
      }
   ]
 }
    """;

    Map<String, dynamic> json = jsonDecode(jsonstr);
    String str = moduleOne(json);

    Widget html = Html(
      data: str,
      style: {
        "td": Style(border: Border.all(color: Colors.red)),
      },
      onLinkTap: (String? url, RenderContext context,
          Map<String, String> attributes, dom.Element? element) {
        print(
            'url=$url attributes:${attributes.entries.first.key}${attributes
                .entries.first.value}');
      },
      customRender: {
        //自定义组件，将组件添加到指定标签中，如上述的flutter标签
        "flutter": (RenderContext context, Widget child) {
          return Text("测试");
        }
      },
      tagsList: Html.tags..addAll(["flutter"]), //配合自定义组件
    );

    String htmlData = """<div>
        <h1 id='title'>Demo Page</h1>
        <p>This is a fantastic product that you should buy!</p>
        <h3>Features</h3>
        <ul>
          <li>It actually works</li>
          <li>It exists</li>
          <li>It doesn't cost much!</li>
          <li><flutter></flutter></li>
        </ul>
        <p><a href='https://github.com'><font color="red">websites</font></a></p>
        <!--You can pretty much put any html in here!-->
      </div>""";
    dom.Document document = htmlparser.parse(htmlData);
    document
        .getElementById("title")
        ?.text = "Demo Page Two";
    Widget html2 = Html.fromDom(document: document);

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
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
              style: Theme
                  .of(context)
                  .textTheme
                  .headline4,
            ),
            html,
            html2
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  String moduleOne(Map<String, dynamic> json) {
    String str = "";
    json.forEach((key, value) {
      if (key == "typeOne") {
        str = typeOne(value, str);
      } else if (key == "typeTwo") {
        str = typeTwo(value, str);
      } else if (key == "typeThree") {
        str = typeThree(value,str);
      }
    });
    return str;
  }

  /**
   * 名称：类型模版
   * 如：  单品条码:B04000000000000750
   */
  String typeOne(List<dynamic> list, String str) {
    list.forEach((element) {
      Map<String, dynamic> content = element;
      str = str + "<p>";
      content.forEach((k, v) {
        str = str + "$v：";
      });
      str = str.substring(0, str.length - 1);
      str = str + "</p></br>";
    });
    return str;
  }

  /**
   * 一行多个类容
   * 如：003274   10   2B  ...
   */
  String typeTwo(List<dynamic> list, String str) {
    list.forEach((element) {
      Map<String, dynamic> content = element;
      str = str + "<p>";
      content.forEach((k, v) {
        str = str + "$v${space(2)}";
      });
      str = str.substring(0, str.length - 1);
      str = str + "</p></br>";
    });
    return str;
  }

  /**
   * 表格模版
   */
  String typeThree(List<dynamic> list, String str) {
    str = str + "<table>";
    list.forEach((element) {
      Map<String, dynamic> content = element;
      str = str +"<tr>";
      content.forEach((key, value) {
        str = str + "<td>$value</td>";
      });
      str = str +"</tr>";
    });
    str = str + "</table>";
    return str;
  }

  /**
   * 非严格
   */
  String space(int nums) {
    String sp = " ";
    for (int i = 0; i < nums; i++) {
      sp = sp + "&nbsp";
    }
    return sp + " ";
  }
}
